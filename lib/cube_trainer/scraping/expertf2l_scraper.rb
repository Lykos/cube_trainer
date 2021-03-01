# frozen_string_literal: true

require 'json'
require 'net/http'
require 'twisty_puzzles'
require 'uri'

module CubeTrainer
  module Scraping
    # Scraper for the expertf2l page.
    class ExpertF2lScraper
      DOMAIN = 'http://algs.expertcuber.by'
      F2lCase = Struct.new(:name, :misoriented_subcase_index, :has_auf)
      F2L_CASES = [
        F2lCase.new('wall', 1, true),
        F2lCase.new('roof', 1, true),
        F2lCase.new('checkerboard', 1, true),
        F2lCase.new('triple sexy', 1, true),
        F2lCase.new('weird watcher', 1, true),
        F2lCase.new('solved edge', 1, true),
        F2lCase.new('free pair', 1, true),
        F2lCase.new('flipped pair', 1, true),
        F2lCase.new('friend', 0, true),
        F2lCase.new('split', 0, true),
        F2lCase.new('short hide', 1, true),
        F2lCase.new('long hide', 1, true),
        F2lCase.new('three mover', 0, true),
        F2lCase.new('pseudo three mover', 0, true),
        F2lCase.new('long penis', 1, true),
        F2lCase.new('short penis', 1, true),
        F2lCase.new('solved corner', 1, true),
        F2lCase.new('hockey stick', 1, true),
        F2lCase.new('broken hockey stick', 0, true),
        F2lCase.new('twisted corner', 1, false),
        F2lCase.new('ugly stuck pieces', 0, false),
        F2lCase.new('flipped edge', 0, false)
      ].freeze

      CaseDescription =
        Struct.new(:f2l_case_index, :slot, :subcase_index, :aufcase_index) do
          def aufcase_suffix
            case aufcase_index
            when 1 then ' + U\''
            when 2 then ' + U2'
            when 3 then ' + U'
            else ''
            end
          end

          def corner_suffix
            case aufcase_index
            when 0 then ' corner in front/back'
            when 1 then ' corner on side'
            when nil then ''
            else raise
            end
          end

          def name
            f2l_case = F2L_CASES[f2l_case_index]
            subcase_suffix =
              if subcase_index == f2l_case.misoriented_subcase_index
                ' misoriented'
              else
                ''
              end
            aufcase_suffix = f2l_case.has_auf ? aufcase_suffix : corner_suffix
            "#{f2l_case.name} #{slot}#{subcase_suffix}#{aufcase_suffix}"
          end
        end

      def scrape_f2l_algs
        base_uri = URI(DOMAIN)
        Net::HTTP.start(base_uri.host, base_uri.port) do |http|
          (0..21).collect_concat do |f2l_case_index|
            path = "data/f2l_#{f2l_case_index + 1}.json"
            uri = URI.join(DOMAIN, path)
            request = Net::HTTP::Get.new(uri)
            response = http.request(request)
            raise 'Unsuccessful crawl.' unless response.is_a?(Net::HTTPSuccess)

            json = JSON.parse(response.body)
            extract_algs(f2l_case_index, json)
          end
        end
      end

      private

      SLOTS = %w[fr fl br bl].freeze

      # Intermediate representation of something that can be resolved to an alg
      # given the intermediate representations of the entire alg set.
      class ResolvableAlg
        extend TwistyPuzzles

        def self.parse(alg_string)
          parts = alg_string.split('+')
          alg = parse_algorithm(parts[0].delete('(').delete(')'))
          case parts.length
          when 1 then AlgWithoutReference.new(alg)
          when 2
            reference = Integer(parts[1].strip) - 1
            AlgWithReference.new(alg, reference)
          else
            raise ArgumentError, 'Only the formats "setup + alg" reference or "alg" are supported.'
          end
        end

        def resolve(alg_set)
          raise NotImplementedError
        end
      end

      # Represents a setup and then a reference to another alg in the same set.
      class AlgWithReference < ResolvableAlg
        def initialize(setup, reference)
          super()
          @setup = setup
          @reference = reference
        end

        # Resolve references based on the given alg set.
        def resolve(alg_set)
          @setup + alg_set[@reference].resolve(alg_set)
        end
      end

      # Adapter for alg to the ResolvableAlg interface.
      class AlgWithoutReference < ResolvableAlg
        def initialize(alg)
          super()
          @alg = alg
        end

        def resolve(_alg_set)
          @alg
        end
      end

      # This case is broken on the website and we need to override which alg we take.
      BROKEN_CASE_DESCRIPTION_ALG_INDICES = {
        CaseDescription.new(16, 'fr', 0, 1).freeze => 1
      }.freeze

      def pick_best_alg(case_description, aufcase_json)
        algs = aufcase_json['algs']
        alg_index = BROKEN_CASE_DESCRIPTION_ALG_INDICES[case_description]
        return algs[alg_index]['alg'] if alg_index

        good_algs = algs.filter { |alg| alg['isGood'] }
        alg = good_algs.empty? ? algs.first : good_algs.first
        alg['alg']
      end

      def extract_slot_algs(f2l_case_index, slot, slot_json)
        slot_json.collect_concat.with_index do |subcase, subcase_index|
          maybe_subcase_index = (subcase_index if slot_json.length > 1)
          aufcases = subcase['cases']
          aufcases.map.with_index do |aufcase, aufcase_index|
            maybe_aufcase_index = (aufcase_index if aufcases.length > 1)
            case_description = CaseDescription.new(
              f2l_case_index, slot, maybe_subcase_index,
              maybe_aufcase_index
            )
            alg = pick_best_alg(case_description, aufcase)
            [case_description, ResolvableAlg.parse(alg)]
          end
        end
      end

      def extract_algs(f2l_case_index, json)
        algs =
          SLOTS.collect_concat do |slot|
            extract_slot_algs(f2l_case_index, slot, json[slot])
          end
        alg_set = algs.map(&:second)
        algs.map { |desc, alg| [desc, alg.resolve(alg_set)] }
      end
    end
  end
end
