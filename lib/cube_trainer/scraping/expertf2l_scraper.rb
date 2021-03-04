# frozen_string_literal: true

require 'cube_trainer/training/alg_hint_parser'
require 'json'
require 'net/http'
require 'twisty_puzzles'
require 'uri'

module CubeTrainer
  module Scraping
    # Scraper for the expertf2l page.
    class ExpertF2lScraper
      F2lCase =
        Struct.new(:name, :has_auf, :has_corner_direction, :orientation_mode) do
          def orientation?
            orientation_mode == :default_is_oriented || orientation_mode == :default_is_misoriented
          end

          def oriented_index
            case orientation_mode
            when :default_is_oriented then 0
            when :default_is_misoriented then 1
            else raise
            end
          end

          def misoriented_index
            1 - oriented_index
          end
        end

      DOMAIN = 'http://algs.expertcuber.by'
      F2L_CASES = [
        F2lCase.new('wall', true, false, :default_is_oriented),
        F2lCase.new('roof', true, false, :default_is_oriented),
        F2lCase.new('checkerboard', true, false, :default_is_oriented),
        F2lCase.new('triple sexy', true, false, :only_oriented),
        F2lCase.new('weird watcher', true, true, :only_misoriented),
        F2lCase.new('solved edge', true, true, :only_oriented),
        F2lCase.new('free pair', true, false, :default_is_misoriented),
        F2lCase.new('flipped pair', true, false, :only_misoriented),
        F2lCase.new('friend', true, false, :default_is_misoriented),
        F2lCase.new('split', true, false, :default_is_misoriented),
        F2lCase.new('short hide', true, false, :default_is_oriented),
        F2lCase.new('long hide', true, false, :default_is_oriented),
        F2lCase.new('three mover', true, false, :default_is_misoriented),
        F2lCase.new('pseudo three mover', true, false, :default_is_misoriented),
        F2lCase.new('long penis', true, false, :default_is_oriented),
        F2lCase.new('short penis', true, false, :default_is_oriented),
        F2lCase.new('solved corner', true, false, :default_is_oriented),
        F2lCase.new('hockey stick', true, false, :default_is_oriented),
        F2lCase.new('broken hockey stick', true, false, :default_is_misoriented),
        F2lCase.new('twisted corner', false, true, :only_oriented),
        F2lCase.new('ugly stuck pieces', false, true, :only_misoriented),
        F2lCase.new('flipped edge', false, false, :only_misoriented)
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

          def back_front
            slot[0] == 'f' ? 'front' : 'back'
          end

          def corner_suffix
            return '' unless f2l_case.has_corner_direction

            case corner_index
            when 0 then " corner in #{back_front}"
            when 1 then ' corner on side'
            else raise
            end
          end

          def corner_index
            if !f2l_case.has_auf
              aufcase_index
            elsif !f2l_case.orientation?
              subcase_index
            else
              raise
            end
          end

          def f2l_case
            @f2l_case ||= F2L_CASES[f2l_case_index]
          end

          def orientation_suffix
            return '' unless f2l_case.orientation?

            case subcase_index
            when f2l_case.oriented_index then ' oriented'
            when f2l_case.misoriented_index then ' misoriented'
            else raise
            end
          end

          def name
            "#{f2l_case.name} #{slot}#{orientation_suffix}#{corner_suffix}#{aufcase_suffix}"
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

        def self.parse_from_json(alg_json)
          parse_from_string(alg_json['alg'])
        end

        def self.parse_from_string(alg_string)
          parts = alg_string.split('+')
          alg = parse_algorithm(parts[0].delete('(').delete(')').gsub("'2", '2'))
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

      def pick_best_alg_json(case_description, algs_json)
        alg_index = BROKEN_CASE_DESCRIPTION_ALG_INDICES[case_description]
        return algs_json[alg_index] if alg_index

        good_algs_json = algs_json.filter { |alg| alg['isGood'] }
        good_algs_json.empty? ? algs_json.first : good_algs_json.first
      end

      def create_unfinished_note(case_description, aufcase_json)
        algs_json = aufcase_json['algs']

        best_alg_json = pick_best_alg_json(case_description, algs_json)
        alternate_algs_json =
          algs_json.select do |a|
            a != best_alg_json && !a['alg'].start_with?('Free')
          end
        {
          case_description: case_description,
          best_alg: ResolvableAlg.parse_from_json(best_alg_json),
          alternate_algs: alternate_algs_json.map { |a| ResolvableAlg.parse_from_json(a) }
        }
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
            create_unfinished_note(case_description, aufcase)
          end
        end
      end

      def extract_algs(f2l_case_index, json)
        notes =
          SLOTS.collect_concat do |slot|
            extract_slot_algs(f2l_case_index, slot, json[slot])
          end
        alg_set = notes.pluck(:best_alg)
        notes.map! do |note|
          {
            case_description: note[:case_description],
            best_alg: note[:best_alg].resolve(alg_set),
            alternate_algs: note[:alternate_algs].map do |a|
                              a.resolve(alg_set)
                            end.join(AlgHintParser::ALTERNATIVE_ALG_SEPARATOR)
          }
        end
      end
    end
  end
end
