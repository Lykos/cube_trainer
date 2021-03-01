require 'json'
require 'net/http'
require 'twisty_puzzles'
require 'uri'

module CubeTrainer
  module Scraping
    # Scraper for the expertf2l page.
    class ExpertF2lScraper
      DOMAIN = "http://algs.expertcuber.by"

      def scrape_f2l_algs
        base_uri = URI(DOMAIN)
        Net::HTTP.start(base_uri.host, base_uri.port) do |http| 
            (1..22).collect_concat do |f2l_case_index|
            path = "data/f2l_#{f2l_case_index}.json"
            puts path
            uri = URI.join(DOMAIN, path)
            request = Net::HTTP::Get.new(uri)
            response = http.request(request)
            raise "Unsuccessful crawl." unless response.is_a?(Net::HTTPSuccess)

            json = JSON.parse(response.body)
            extract_algs(f2l_case_index, json)
          end
        end
      end

      private

      SLOTS = %w(fr fl br bl)

      class ResolvableAlg
        extend TwistyPuzzles

        def self.parse(alg_string)
          parts = alg_string.split('+')
          alg = parse_algorithm(parts[0].gsub('(', '').gsub(')', ''))
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
          @alg = alg
        end

        def resolve(alg_set)
          @alg
        end
      end

      CaseDescription = Struct.new(:f2l_case_index, :slot, :subcase_index, :aufcase_index)

      # This case is broken on the website and we need to override which alg we take.
      BROKEN_CASE_DESCRIPTION_ALG_INDICES = {
        CaseDescription.new(17, 'fr', 0, 1).freeze => 1
      }.freeze

      def pick_best_alg(case_description, aufcase_json)
        algs = aufcase_json["algs"]
        alg_index = BROKEN_CASE_DESCRIPTION_ALG_INDICES[case_description]
        return algs[alg_index]["alg"] if alg_index

        good_algs = algs.filter { |alg| alg["isGood"] }
        alg = good_algs.empty? ? algs.first : good_algs.first
        alg["alg"]
      end

      def extract_algs(f2l_case_index, json)
        alg_set = SLOTS.collect_concat do |slot|
          json[slot].collect_concat.with_index do |subcase, subcase_index|
            subcase["cases"].map.with_index do |aufcase, aufcase_index|
              case_description = CaseDescription.new(f2l_case_index, slot, subcase_index, aufcase_index)
              alg = pick_best_alg(case_description, aufcase)
              ResolvableAlg.parse(alg)
            end
          end
        end
        alg_set.map { |alg| alg.resolve(alg_set) }
      end
    end
  end
end
