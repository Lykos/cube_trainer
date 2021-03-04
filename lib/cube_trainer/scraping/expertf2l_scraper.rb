# frozen_string_literal: true

require 'cube_trainer/training/alg_hint_parser'
require 'cube_trainer/training/case_solution'
require 'cube_trainer/anki/cube_mask'
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

      CUBE_SIZE = 3
      DOMAIN = 'http://algs.expertcuber.by'
      F2L_CASES = [
        nil,
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

          def inspect
            "CaseDescription(#{f2l_case_index}, '#{slot}', #{subcase_index}, #{aufcase_index})"
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

          def to_s
            "#{f2l_case.name} #{slot}#{orientation_suffix}#{corner_suffix}#{aufcase_suffix}"
          end
        end

      def initialize
        @solved_cube_state = TwistyPuzzles::ColorScheme::WCA.solved_cube_state(CUBE_SIZE)
        Anki::CubeMask.from_name(:ll, CUBE_SIZE, :undefined).apply_to(@solved_cube_state)
      end

      def scrape_f2l_algs
        @case_descriptions_to_fixed_algs = CASE_DESCRIPTIONS_TO_FIXED_ALGS.dup
        base_uri = URI(DOMAIN)
        algs = Net::HTTP.start(base_uri.host, base_uri.port) do |http|
          (1..22).collect_concat do |f2l_case_index|
            path = "data/f2l_#{f2l_case_index}.json"
            uri = URI.join(DOMAIN, path)
            request = Net::HTTP::Get.new(uri)
            response = http.request(request)
            raise 'Unsuccessful crawl.' unless response.is_a?(Net::HTTPSuccess)

            json = JSON.parse(response.body)
            extract_algs(f2l_case_index, json)
          end
        end
        check_fixed_algs_used_up
        algs
      end

      def check_fixed_algs_used_up
        return if @case_descriptions_to_fixed_algs.empty?

        remaining = @case_descriptions_to_fixed_algs.keys.map { |k| "[#{k[0].inspect}, #{k[1]}]" }.join(", ")
        raise "Some alg fixes were unused: #{remaining}"
      end

      private

      SLOTS = %w[fr fl br bl].freeze

      # Intermediate representation of something that can be resolved to an alg
      # given the intermediate representations of the entire alg set.
      class ResolvableAlg
        extend TwistyPuzzles

        def self.parse(alg_string)
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

        attr_reader :setup, :reference

        def to_s
          "#{@setup} + #{@reference}"
        end

        # Resolve references based on the given alg set.
        def resolve(alg_set)
          (@setup + alg_set[@reference].resolve(alg_set))
        end

        def eql?(other)
          self.class.equal?(other.class) && @setup == other.setup && @reference == other.reference
        end

        alias == eql?

        def hash
          @hash ||= [self.class, @setup, @reference].hash
        end
      end

      # Adapter for alg to the ResolvableAlg interface.
      class AlgWithoutReference < ResolvableAlg
        def initialize(alg)
          super()
          @alg = alg
        end

        attr_reader :alg

        def to_s
          @alg.to_s
        end

        def resolve(_alg_set)
          @alg
        end

        def eql?(other)
          self.class.equal?(other.class) && @alg == other.alg
        end

        alias == eql?

        def hash
          @hash ||= [self.class, @alg].hash
        end
      end

      # This case doesn't have a good "best alg" on the website and we need to override which alg we take.
      CASE_DESCRIPTIONS_TO_BEST_ALG_INDICES = {
        CaseDescription.new(17, 'fr', 0, 1) => 1
      }.freeze

      # These algs are broken on the website and we override them with fixed ones.
      CASE_DESCRIPTIONS_TO_FIXED_ALGS = {
        [CaseDescription.new(4, 'fr', nil, 2), ResolvableAlg.parse("R U Rw' U Rw U Rw' U' M'")] => ResolvableAlg.parse("R U Rw' U Rw U' Rw' U' M'"),
        [CaseDescription.new(5, 'fl', 1, 0), ResolvableAlg.parse("L' U L' Dw R U' R' U R U R'")] => ResolvableAlg.parse("L' U L Dw R U' R' U R U R'"),
        [CaseDescription.new(6, 'bl', 0, 1), ResolvableAlg.parse("U2 + 20")] => ResolvableAlg.parse("U2 + 28"),
        [CaseDescription.new(7, 'fr', 1, 3), ResolvableAlg.parse("R U' R")] => ResolvableAlg.parse("R U' R'"),
        [CaseDescription.new(7, 'bl', 0, 0), ResolvableAlg.parse("y U R' U R")] => ResolvableAlg.parse("y U' R' U R"),
        [CaseDescription.new(7, 'bl', 0, 1), ResolvableAlg.parse("y' U2 L' U' L")] => ResolvableAlg.parse("y' U2 L' U L"),
        [CaseDescription.new(9, 'fl', 0, 3), ResolvableAlg.parse("L' U L M' U' L' U L' U' L' U L")] => ResolvableAlg.parse("L' U L M' U' L' U L U' L' U Lw"),
        [CaseDescription.new(10, 'fr', 0, 1), ResolvableAlg.parse("Dw' U' L' U L U' L' U'")] => ResolvableAlg.parse("Dw' U' L' U L U' L' U' L"),
        [CaseDescription.new(12, 'fl', 1, 3), ResolvableAlg.parse("y' R U2 R U2 R U' R'")] => ResolvableAlg.parse("y' R U2 R' U2 R U' R'"),
        [CaseDescription.new(14, 'bl', 0, 1), ResolvableAlg.parse("y' R' U' R U' R' U' R")] => ResolvableAlg.parse("y R' U' R U' R' U' R"),
        [CaseDescription.new(16, 'bl', 0, 0), ResolvableAlg.parse("L U' L U2 L U L'")] => ResolvableAlg.parse("L U' L' U2 L U L'"),
        [CaseDescription.new(17, 'br', 1, 3), ResolvableAlg.parse("y U' R' F' R U R U' R' F'")] => ResolvableAlg.parse("y U' R' F' R U R U' R' F"),
        [CaseDescription.new(20, 'bl', nil, 1), ResolvableAlg.parse("L U L' U L U2 L' U L U' L'")] => ResolvableAlg.parse("L U' L' UL U2 L' U L U' L'")
      }.freeze

      def pick_best_alg_index(case_description, algs_json)
        CASE_DESCRIPTIONS_TO_BEST_ALG_INDICES[case_description] ||
          algs_json.find_index { |alg| alg['isGood'] } || 0
      end

      def extract_alg(case_description, alg_json)
        parsed_alg = ResolvableAlg.parse(alg_json['alg'])
        @case_descriptions_to_fixed_algs.delete([case_description, parsed_alg]) ||
          parsed_alg
      end

      def create_unfinished_note(case_description, aufcase_json)
        algs_json = aufcase_json['algs'].reject { |a| a['alg'].start_with?('Free') }
        best_alg_index = pick_best_alg_index(case_description, algs_json)
        algs = algs_json.map { |a| extract_alg(case_description, a) }
        {
          case_description: case_description,
          best_alg: algs[best_alg_index],
          alternative_algs: algs[0...best_alg_index] + algs[best_alg_index + 1..-1]
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
          best_alg = note[:best_alg].resolve(alg_set)
          alternative_algs = note[:alternative_algs].map do |a|
            a.resolve(alg_set)
          end
          case_solution = Training::CaseSolution.new(best_alg, alternative_algs)
          case_solution.check_alg_equivalence("#{note[:case_description]} (#{note[:case_description].inspect})", @solved_cube_state)
          {
            case_description: note[:case_description],
            case_solution: case_solution
          }
        end
      end
    end
  end
end
