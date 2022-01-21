# frozen_string_literal: true

# Model for possible achievements.
# Note that it does NOT include which users have them.
# TODO: Remove now that it exists in the frontend.
class Achievement < ActiveModelSerializers::Model
  derive_attributes_from_names_and_fix_accessors
  attributes :id, :name, :description

  validates :id, presence: true
  validates :name, presence: true

  ALL = [
    Achievement.new(id: :fake, name: 'Fake', description: 'Fake achievement for tests.'),
    Achievement.new(
      id: :training_session_creator,
      name: 'Training Session Creator',
      description: 'You figured out how to use this website and created your first ' \
                   'training session!'
    ),
    Achievement.new(
      id: :statistician,
      name: 'Statistician',
      description: 'You assigned your first stat to a training session!'
    ),
    Achievement.new(
      id: :enthusiast,
      name: 'Enthusiast',
      description: 'You have a training session with more than 100 results!'
    ),
    Achievement.new(
      id: :addict,
      name: 'Addict',
      description: 'You have a training session with more than 1000 results!'
    ),
    Achievement.new(
      id: :professional,
      name: 'Professional',
      description: 'You have a training session with more than 10000 results!'
    ),
    Achievement.new(
      id: :wizard,
      name: 'Wizard',
      description: 'You have a training session with more than 100000 results!'
    ),
    Achievement.new(
      id: :alg_overrider,
      name: 'AlgOverrider',
      description: 'You used an alg override!'
    )
  ].freeze
  ALL.each(&:validate!)
  BY_ID = ALL.index_by(&:id).freeze

  def self.find_by(id:)
    BY_ID[id.to_sym]
  end

  def self.find_by!(id:)
    find_by(id: id) || (raise ArgumentError)
  end

  def self.find(id)
    find_by!(id: id) # rubocop:disable Rails/FindById
  end
end
