# frozen_string_literal: true

require 'cube_trainer/alg_name'
require 'cube_trainer/training/input_sampler'
require 'cube_trainer/training/result_history'
require 'ostruct'
require 'twisty_puzzles'
require 'twisty_puzzles/utils'

module CubeTrainer
  module Training
    # Represents a score that is not present and unknown.
    class UnknownScore
      include Comparable
      def <=>(other)
        -other.unknown_compare
      end

      def +(_other)
        self
      end

      def unknown_compare
        0
      end

      def actual_compare(_value)
        1
      end

      def plus_actual(_value)
        self
      end

      def -@
        self
      end

      def to_s
        'unknown'
      end

      def known?
        false
      end
    end

    # Represents a score that is actually present and known.
    class ActualScore
      include Comparable
      def initialize(value)
        @value = value
      end

      def <=>(other)
        -other.actual_compare(@value)
      end

      def +(other)
        other.plus_actual(@value)
      end

      def actual_compare(value)
        @value <=> value
      end

      def unknown_compare
        -1
      end

      def plus_actual(value)
        ActualScore.new(@value + value)
      end

      def -@
        ActualScore.new(-@value)
      end

      def to_s
        if @value.is_a?(Float)
          @value.round(2).to_s
        else
          @value.to_s
        end
      end

      def known?
        true
      end
    end

    # Hinter that gives hints on how to solve a certain case based on a sequence of primitive cases,
    # e.g. solving a corner twist and a parity by a comm and a parity.
    class HeterogenousSequenceHinter
      include TwistyPuzzles::Utils::ArrayHelper
      DescriptionAndValue =
        Struct.new(:description, :value, :cancellations) do
          def <=>(other)
            [-cancellations, value, description] <=>
              [-other.cancellations, other.value, other.description]
          end

          def to_s
            cancellations_string =
              if cancellations > ActualScore.new(0)
                " (cancels #{cancellations})"
              else
                ''
              end
            "#{description}: #{value}#{cancellations_string}"
          end
        end
      UNKNOWN_SCORE = UnknownScore.new

      def initialize(cube_size, modes, hinters)
        TwistyPuzzles::CubeState.check_cube_size(cube_size)
        raise TypeError unless modes.all? { |m| m.is_a?(Mode) }
        raise ArgumentError if modes.length != hinters.length || modes.empty?

        hinters.each do |h|
          raise TypeError, "Got invalid hinter type #{h.class}." unless h.respond_to?(:hints)
        end
        @cube_size = cube_size
        @valuess = compute_valuess(modes)
        @hinters = hinters
        @hints = {}
        @metric = :sqtm
      end

      def compute_valuess(modes)
        modes.map do |mode|
          values = {}
          # TODO: get values for options in a more future proof way.
          result_history = ResultHistory.new(
            mode: mode,
            badness_memory: InputSampler::DEFAULT_CONFIG[:badness_memory],
            hint_seconds: InputSampler::DEFAULT_CONFIG[:hint_seconds],
            failed_seconds: InputSampler::DEFAULT_CONFIG[:failed_seconds]
          )
          result_history.badness_averages.each do |r, b|
            values[r] = ActualScore.new(b)
          end
          values
        end
      end

      def length
        @hinters.length
      end

      def value(index, input)
        @valuess[index][input] ||= UNKNOWN_SCORE
      end

      def base_hint(index, input)
        raise IndexError unless index >= 0 && index < length

        hints = @hinters[index].hints(input)
        hints.empty? ? nil : only(hints)
      end

      def combinations_with_base_hints(combinations)
        combinations.map do |ls|
          [ls, ls.map.with_index { |l, i| base_hint(i, l) }]
        end
      end

      def binary_cancellation_score(left, right)
        if left && right
          ActualScore.new(left.cancellations(right, @cube_size, @metric))
        else
          UNKNOWN_SCORE
        end
      end

      def sequence_cancellation_score(sequence)
        sequence[0..-2].zip(sequence[1..-1]).sum do |left, right|
          binary_cancellation_score(left, right)
        end
      end

      def descriptions_and_values(combinations_with_base_hints)
        combinations_with_base_hints.map do |ls, hs|
          description = ls.join(', ')
          value = ls.map.with_index { |l, i| value(i, l) }.sum
          cancellations = sequence_cancellation_score(hs)
          DescriptionAndValue.new(description, value, cancellations)
        end
      end

      def base_hints_descriptions(combinations_with_base_hints)
        combinations_with_base_hints.map do |ls, hs|
          ls.zip(hs).select { |_l, h| h }.map { |l, h| "#{l}: #{h}" }
        end.flatten.uniq
      end

      def hints(input)
        @hints[input] ||=
          begin
            combinations = generate_combinations(input)
            stuff = combinations_with_base_hints(combinations)
            [
              descriptions_and_values(stuff).sort.join("\n"),
              base_hints_descriptions(stuff).sort.join("\n")
            ]
          end
      end

      def generate_combinations(_input)
        raise NotImplementedError
      end
    end

    # Hinter that gives hints on how to solve a certain case based on a sequence of primitive cases,
    # where the primitive cases are all of the same type, e.g. solving 3 twists by 2 comms.
    class HomogenousSequenceHinter < HeterogenousSequenceHinter
      def initialize(cube_size, results, hinter, multiplicity = 2)
        super(cube_size, [results] * multiplicity, [hinter] * multiplicity)
      end
    end

    # Hinter that gives hints on how to solve a sequence of algs.
    class AlgSequenceHinter
      include TwistyPuzzles::Utils::ArrayHelper

      def initialize(hinters)
        hinters.each do |h|
          unless h.respond_to?(:hints) && h.respond_to?(:entries)
            raise TypeError, "Got invalid hinter type #{h.class}."
          end
        end
        raise ArgumentError if hinters.empty?

        @hinters = hinters
      end

      def hints(input)
        parts = input_parts(input)
        hint_components = @hinters.zip(parts).map { |h, i| only(h.hints(i)) }
        [hint_components.sum]
      end

      def entries
        entries_components = @hinters.map(&:entries)
        entries_components[0].product(*entries_components[1..-1]).map do |entry_combination|
          name = entry_combination.sum { |e| e[0] }
          alg = entry_combination.sum { |e| e[1] }
          [name, alg]
        end
      end

      def input_parts(input)
        parts = input.sub_names
        raise ArgumentError unless @hinters.length == parts.length

        parts
      end
    end
  end
end
