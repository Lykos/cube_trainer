# frozen_string_literal: true

require 'twisty_puzzles'

# Model for stats.
# Note that it does NOT include which training_sessions have them.
class StatType
  include ActiveModel::Model
  attr_accessor :key, :name, :description, :parts, :needs_bounded_inputs

  STAT_PART_TYPES = %i[time fraction count].freeze

  validates :key, presence: true
  validates :name, presence: true
  validates :parts, presence: true
  validate :part_types_valid

  alias needs_bounded_inputs? needs_bounded_inputs

  def part_types_valid
    return if (parts.map(&:type) - STAT_PART_TYPES).empty?

    errors.add(:parts, "has to be a subset of all stat part types #{STAT_PART_TYPES.inspect}")
  end

  def to_simple
    {
      key: key,
      name: name,
      description: description
    }
  end

  def stat_parts(training_session)
    parts.map { |part| part.calculate(training_session) }
  end

  def self.time_s_expression
    # TODO: Use SqlHelper
    Arel::Nodes::Case
      .new(Result.arel_table[:success])
      .when(Arel::Nodes::True.new)
      .then(Result.arel_table[:time_s])
      .else(Arel::Nodes::Quoted.new('Infinity'))
  end

  # Stat part that computes a value like an ao5 or the number of successes.
  class StatPart
    def calculate(training_session)
      {
        name: name,
        stat_part_type: type,
        time_s: calculate_time_s(training_session),
        success: calculate_success(training_session),
        count: calculate_count(training_session),
        fraction: calculate_fraction(training_session)
      }.compact
    end

    def calculate_success(training_session)
      calculate_time_s_internal(training_session)&.finite?
    end

    def calculate_time_s(training_session)
      value = calculate_time_s_internal(training_session)
      value&.finite? ? value : nil
    end

    def calculate_time_s_internal(training_session); end

    def calculate_fraction(training_session); end

    def calculate_count(training_session); end
  end

  # Stat part that computes an average like ao5.
  class Average < StatPart
    def initialize(size)
      super()
      @size = size
    end

    def type
      :time
    end

    def calculate_time_s_internal(training_session)
      times =
        training_session
        .results
        .limit(@size)
        .pluck(StatType.time_s_expression)
      TwistyPuzzles::Native::CubeAverage.new(@size, Float::NAN).push_all(times)
    end

    def name
      "ao#{@size}"
    end
  end

  # Stat part that computes an average like ao5.
  class SuccessAverage < StatPart
    def initialize(size)
      super()
      @size = size
    end

    def type
      :time
    end

    def calculate_time_s_internal(training_session)
      times =
        training_session
        .results
        .where(Result.arel_table[:success])
        .limit(@size)
        .pluck(Result.arel_table[:time_s])
      TwistyPuzzles::Native::CubeAverage.new(@size, Float::NAN).push_all(times)
    end

    def name
      "ao#{@size} of successes"
    end
  end

  # Stat part that computes the success rate of the last k solves.
  class SuccessRate < StatPart
    def initialize(size)
      super()
      @size = size
    end

    def type
      :fraction
    end

    def calculate_fraction(training_session)
      num_successes_expression =
        Arel::Nodes::Case.new(Result.arel_table[:success])
                         .when(Arel::Nodes::True.new)
                         .then(1.0)
                         .else(0.0)
                         .sum
      total_expression = Result.arel_table[:success].count
      training_session
        .results
        .limit(@size)
        .pick(num_successes_expression / total_expression)
    end

    def name
      "Success rate of #{@size}"
    end
  end

  # Stat part that computes a mean like mo5.
  class Mean < StatPart
    def initialize(size)
      super()
      @size = size
    end

    def type
      :time
    end

    def calculate_time_s_internal(training_session)
      training_session
        .results
        .limit(@size)
        .pick(StatType.time_s_expression.average)
    end

    def name
      "mo#{@size}"
    end
  end

  # Stat part that computes the number of cases that have already been seen.
  class CasesDone < StatPart
    def type
      :count
    end

    def calculate_count(training_session)
      case_keys_seen =
        training_session.results.pluck(:case_key).uniq
      valid_case_keys =
        training_session.cases.map(&:case_key)
      (case_keys_seen & valid_case_keys).length
    end

    def name
      'items seen'
    end
  end

  # Stat part that computes the total number of cases.
  class TotalCases < StatPart
    def type
      :count
    end

    def calculate_count(training_session)
      training_session.cases.length
    end

    def name
      'total items'
    end
  end

  ALL = [
    StatType.new(
      key: :averages,
      name: 'Averages',
      description: 'Averages like ao5, ao12, ao50, etc..',
      needs_bounded_inputs: false,
      parts: [5, 12, 50, 100, 1000, 1000].map { |i| Average.new(i) }
    ),
    StatType.new(
      key: :success_averages,
      name: 'Averages of Successes',
      description: 'Averages like ao5, ao12, ao50, etc..',
      needs_bounded_inputs: false,
      parts: [5, 12, 50, 100, 1000, 1000].map { |i| SuccessAverage.new(i) }
    ),
    StatType.new(
      key: :success_rates,
      name: 'Success Rates',
      description: 'Success Rates in the last 5, 12 50, etc. solves.',
      needs_bounded_inputs: false,
      parts: [5, 12, 50, 100, 1000, 1000].map { |i| SuccessRate.new(i) }
    ),
    StatType.new(
      key: :mo3,
      name: 'Mean of 3',
      needs_bounded_inputs: false,
      parts: [Mean.new(3)]
    ),
    StatType.new(
      key: :progress,
      name: 'Progress',
      needs_bounded_inputs: true,
      parts: [CasesDone.new, TotalCases.new]
    )
  ].freeze
  ALL.each(&:validate!)
  BY_KEY = ALL.index_by(&:key).freeze

  def self.find_by(key:)
    BY_KEY[key.to_sym]
  end

  def self.find_by!(key:)
    find_by(key: key) || (raise ArgumentError)
  end
end
