# frozen_string_literal: true

require 'cube_trainer/native'

# Model for stats.
# Note that it does NOT include which modes have them.
class StatType
  include ActiveModel::Model
  attr_accessor :key, :name, :description, :parts

  validates :key, presence: true
  validates :name, presence: true
  validates :parts, presence: true

  def to_simple
    {
      key: key,
      name: name,
      description: description
    }
  end

  def stat_parts(mode)
    parts.map do |part|
      { name: part.name, time_s: part.calculate(mode) }
    end
  end

  def self.time_s_expression
    Arel::Nodes::Case
      .new(Result.arel_table[:success])
      .when(Arel::Nodes::True.new)
      .then(Result.arel_table[:time_s])
      .else(Arel::Nodes::Quoted.new('Infinity'))
  end

  class Average
    def initialize(size)
      @size = size
    end

    def calculate(mode)
      times =
        mode
        .inputs
        .joins(:result)
        .limit(@size)
        .pluck(StatType.time_s_expression)
      CubeTrainer::Native::CubeAverage.new(@size, Float::NAN).push_all(times)
    end

    def name
      "ao#{@size}"
    end
  end

  class Mean
    def initialize(size)
      @size = size
    end

    def calculate(mode)
      times =
        mode
        .inputs
        .joins(:result)
        .limit(@size)
        .pluck(StatType.time_s_expression.average)
    end

    def name
      "mo#{@size}"
    end
  end

  ALL = [
    StatType.new(
      key: :averages,
      name: 'Averages',
      description: 'Averages like ao5, ao12, ao50, etc..',
      parts: [5, 12, 50, 100, 1000, 1000].map { |i| Average.new(i) }
    ),
    StatType.new(
      key: :mo3,
      name: 'Mean of 3',
      parts: [Mean.new(3)]
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
