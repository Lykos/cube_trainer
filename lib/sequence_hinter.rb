require 'cube_average'
require 'input_sampler'
require 'ostruct'

module CubeTrainer

  # Hinter that gives hints on how to solve a certain case based on a sequence of primitive cases,
  # e.g. solving a corner 3 twist by 2 comms.
  class SequenceHinter
    def initialize(results, hinter)
      @values = {}
      results.group_by { |r| r.input }.each do |l, rs|
        avg = CubeAverage.new(InputSampler::BADNESS_MEMORY, 0)
        rs.sort_by { |r| r.timestamp }.each { |r| avg.push(r.time_s) }
        @values[l] = ActualScore.new(avg.average)
      end
      @hinter = hinter
      @hints = {}
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

    def value(letter_pair)
      @values[letter_pair] ||= UNKNOWN_SCORE
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

    def hint(letter_pair)
      @hints[letter_pair] ||= begin
                                combinations = generate_combinations(letter_pair)
                                descriptions_and_values = 
                                  combinations.map do |ls|
                                  value = ls.map { |l| value(l) }.reduce(:+)
                                  cancellations = 0.upto(ls.length - 2).map do |i|
                                    left = @hinter.hint(ls[0])
                                    right = @hinter.hint(ls[1])
                                    if left && right
                                      ActualScore.new(left.cancellations(right, :sqtm))
                                    else
                                      UNKNOWN_SCORE
                                    end
                                  end.reduce(:+)
                                  description = ls.join(', ')
                                  DescriptionAndValue.new(description, value, cancellations)
                                end
                                base_hints = combinations.flatten.uniq.map { |l| "#{l}: #{@hinter.hint(l)}" }
                                (descriptions_and_values.sort + base_hints.sort).join("\n")
                              end
    end

    def generate_combinations(letter_pair)
      raise NotImplementedError
    end

  end
  
end
