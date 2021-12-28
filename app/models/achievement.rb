# frozen_string_literal: true

# Model for possible achievements.
# Note that it does NOT include which users have them.
class Achievement
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
    Achievement.new(key: :fake, name: 'Fake', description: 'Fake achievement for tests.'),
    Achievement.new(
      key: :training_session_creator,
      name: 'Training Session Creator',
      description: 'You figured out how to use this website and created your first ' \
                   'training session!'
    ),
    Achievement.new(
      key: :stat_creator,
      name: 'Statistician',
      description: 'You assigned your first stat to a mode!'
    ),
    Achievement.new(
      key: :alg_overrider,
      name: 'AlgOverrider',
      description: 'You used an alg override!'
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
