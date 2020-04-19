# frozen_string_literal: true

# Model for stats.
# Note that it does NOT include which modes have them.
class Stat
  include ActiveModel::Model
  attr_accessor :key, :name, :description

  validates :key, presence: true
  validates :name, presence: true

  def to_simple
    {
      key: key,
      name: name,
      description: description
    }
  end

  ALL = [
    Stat.new(
      key: :averages,
      name: 'Averages',
      description: 'Averages like ao5, ao12, ao50, etc..'
    ),
    Stat.new(
      key: :mo3,
      name: 'Mean of 3'
    ),
    Stat.new(
      key: :averages_per_input_item,
      name: 'Averages per Input Item',
      description: 'Averages like ao5, ao12, ao50, etc. per input item. Note that this makes almost no sense for modes where the input is a scramble since every single scramble would be counted separately.'
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
