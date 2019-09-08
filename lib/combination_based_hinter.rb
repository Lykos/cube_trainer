require 'cube_average'
require 'input_sampler'

module CubeTrainer

  # Hinter that gives hints on how to solve a certain case based on a combination of primitive cases,
  # e.g. solving a corner 3 twist by 2 comms.
  class CombinationBasedHinter
    def initialize(results)
      @values = {}
      results.group_by { |r| r.letter_pair }.each do |l, rs|
        avg = CubeAverage.new(InputSampler::BADNESS_MEMORY, 0)
        rs.sort { |r| r.timestamp }.each { |r| avg.push(r) }
        @values[l] = avg.average
      end
      @hints = {}
    end

    def value(letter_pair)
      @values[letter_pair] || 'unknown'
    end

    def hint(letter_pair)
      @hints[letter_pair] ||= generate_combinations(letter_pair).map do |ls|
        value = ls.map { |l| value(l) }.reduce(:+)
        description = ls.join(', ')
        "#{description}: #{value}"
      end.join('; ')
    end

    def generate_combinations(letter_pair)
      raise NotImplementedError
    end

  end
  
end
