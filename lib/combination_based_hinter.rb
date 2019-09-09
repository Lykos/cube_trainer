require 'cube_average'
require 'input_sampler'
require 'ostruct'

module CubeTrainer

  # Hinter that gives hints on how to solve a certain case based on a combination of primitive cases,
  # e.g. solving a corner 3 twist by 2 comms.
  class CombinationBasedHinter
    def initialize(results)
      @values = {}
      results.group_by { |r| r.input }.each do |l, rs|
        avg = CubeAverage.new(InputSampler::BADNESS_MEMORY, 0)
        rs.sort_by { |r| r.timestamp }.each { |r| avg.push(r.time_s) }
        @values[l] = ActualScore.new(avg.average)
      end
      @hints = {}
    end

    class UnknownScore
      def <=>(score)
        -score.unknown_compare
      end

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
    end

    UNKNOWN_SCORE = UnknownScore.new

    class ActualScore
      def initialize(value)
        @value = value
      end

      def <=>(score)
        -score.actual_compare(@value)
      end

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
        @value.round(2).to_s
      end
    end

    def value(letter_pair)
      @values[letter_pair] ||= UNKNOWN_SCORE
    end

    class DescriptionAndValue < Struct.new(:description, :value)
      def <=>(other)
        [value, description] <=> [other.value, other.description]
      end

      def to_s
        "#{description}: #{value}"
      end
    end

    def hint(letter_pair)
      @hints[letter_pair] ||= begin
                                descriptions_and_values = 
                                  generate_combinations(letter_pair).map do |ls|
                                  value = ls.map { |l| value(l) }.reduce(:+)
                                  description = ls.join(', ')
                                  DescriptionAndValue.new(description, value)
                                end
                                descriptions_and_values.sort.join("\n")
                              end
    end

    def generate_combinations(letter_pair)
      raise NotImplementedError
    end

  end
  
end
