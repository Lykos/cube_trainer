require 'cube_trainer/cube_average'
require 'cube_trainer/input_sampler'
require 'ostruct'
require 'cube_trainer/array_helper'
require 'cube_trainer/alg_name'

module CubeTrainer

  # Hinter that gives hints on how to solve a certain case based on a sequence of primitive cases,
  # e.g. solving a corner twist and a parity by a comm and a parity.
  class HeterogenousSequenceHinter

    include ArrayHelper

    def initialize(resultss, hinters)
      raise ArgumentError if resultss.length != hinters.length
      raise ArgumentError if resultss.empty?
      @valuess = resultss.map do |results|
        values = {}
        results.group_by { |r| r.input_representation }.each do |l, rs|
          avg = CubeAverage.new(InputSampler::BADNESS_MEMORY, 0)
          rs.sort_by { |r| r.timestamp }.each { |r| avg.push(r.time_s) }
          values[l] = ActualScore.new(avg.average)
        end
        values
      end
      @hinters = hinters
      @hints = {}
    end

    def length
      @hinters.length
    end

    class UnknownScore
      def <=>(score)
        -score.unknown_compare
      end

      include Comparable

      def +(score)
        self
      end

      def unknown_compare
        0
      end

      def actual_compare(value)
        1
      end

      def plus_actual(value)
        self
      end

      def to_s
        'unknown'
      end

      def known?
        false
      end
    end

    UNKNOWN_SCORE = UnknownScore.new

    class ActualScore
      def initialize(value)
        @value = value
      end

      def <=>(score)
        -score.actual_compare(@value)
      end

      include Comparable

      def +(score)
        score.plus_actual(@value)
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

    def value(index, input)
      @valuess[index][input] ||= UNKNOWN_SCORE
    end

    class DescriptionAndValue < Struct.new(:description, :value, :cancellations)
      def <=>(other)
        [value, other.cancellations, description] <=> [other.value, other.cancellations, other.description]
      end

      def to_s
        cancellations_string = if cancellations > ActualScore.new(0)
                                 " (cancels #{cancellations})"
                               else
                                 ""
                               end
        "#{description}: #{value}#{cancellations_string}"
      end
    end

    def base_hint(index, input)
      raise IndexError unless index >= 0 && index < length
      hints = @hinters[index].hints(input)
      if hints.empty? then nil else only(hints) end
    end

    def hints(input)
      @hints[input] ||= begin
                          combinations = generate_combinations(input)
                          base_hints = combinations.map { |ls| ls.map.with_index { |l, i| base_hint(i, l) } }
                          descriptions_and_values = combinations.zip(base_hints).map do |ls, hs|
                            description = ls.join(', ')
                            value = ls.map.with_index { |l, i| value(i, l) }.reduce(:+)
                            cancellations = hs[0..-2].zip(hs[1..-1]).map do |left, right|
                              if left && right
                                ActualScore.new(left.cancellations(right, :sqtm))
                              else
                                UNKNOWN_SCORE
                              end
                            end.reduce(:+)
                            DescriptionAndValue.new(description, value, cancellations)
                          end
                          base_hints_descriptions = combinations.zip(base_hints).map { |ls, hs| ls.zip(hs).select { |l, h| h }.map { |l, h| "#{l}: #{h}" } }
                          [
                            descriptions_and_values.sort.join("\n"),
                            base_hints_descriptions.sort.join("\n")
                          ]
                        end
    end

    def generate_combinations(input)
      raise NotImplementedError
    end

  end

  # Hinter that gives hints on how to solve a certain case based on a sequence of primitive cases,
  # where the primitive cases are all of the same type, e.g. solving 3 twists by 2 comms.
  class HomogenousSequenceHinter < HeterogenousSequenceHinter
    def initialize(results, hinter, multiplicity=2)
      super([results] * multiplicity, [hinter] * multiplicity)
    end
  end
  
  class AlgSequenceHinter

    include ArrayHelper

    def initialize(hinters, separator)
      hinters.each do |h|
        raise TypeError, "Got invalid hinter type #{h.class}." unless h.respond_to?(:hints) && h.respond_to?(:entries)
      end
      raise ArgumentError if hinters.empty?
      @hinters = hinters
      @separator = separator
    end

    def hints(input)
      parts = input_parts(input)
      hint_components = @hinters.zip(parts).map { |h, i| only(h.hints(i)) }
      [hint_components.reduce(:+)]
    end

    def entries
      entries_components = @hinters.map { |h| h.entries }
      entries_components[0].product(*entries_components[1..-1]).map do |entry_combination|
        name = entry_combination.map { |e| e[0] }.join(@separator)
        alg = entry_combination.map { |e| e[1] }.reduce(:+)
        [name, alg]
      end
    end

    def input_parts(input)
      parts = input.to_s.split(@separator).map { |i| AlgName.new(i) }
      raise ArgumentError unless @hinters.length == parts.length
      parts
    end
  end

end
