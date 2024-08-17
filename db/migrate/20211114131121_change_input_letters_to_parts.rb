require 'twisty_puzzles'
require 'cube_trainer/letter_pair'

class ChangeInputLettersToParts < ActiveRecord::Migration[6.0]
  class User < ApplicationRecord
    has_many :modes
    has_one :letter_scheme
  end

  class Mode < ApplicationRecord
    # TODO: Using a type here is bad because it might be deleted.
    attribute :mode_type, :training_session_type
    attribute :buffer, :part

    belongs_to :user
    has_many :inputs
  end

  class Input < ApplicationRecord
    belongs_to :mode
    attribute :input_representation, :input_representation
  end

  def change
    reversible do |change|
      change.up do
        User.all.each do |user|
          letter_scheme = TwistyPuzzles::BernhardLetterScheme.new
          user.modes.each do |mode|
            mode.inputs.each do |input|
              next unless input.input_representation.is_a?(CubeTrainer::LetterPair)
              next unless mode.mode_type.letter_scheme_mode

              letter_pair = input.input_representation
              part_cycle =
                case mode.mode_type.letter_scheme_mode
                when :buffer_plus_2_parts
                  TwistyPuzzles::PartCycle.new([mode.buffer] + letter_pair.letters.map { |l| letter_scheme.for_letter(mode.mode_type.part_type, l) })
                when :simple
                  TwistyPuzzles::PartCycle.new(letter_pair.letters.map { |l| letter_scheme.for_letter(mode.mode_type.part_type, l) })
                else
                  raise
                end
              input.update(input_representation: part_cycle)
            end
          end
        end
      end
      change.down do
        User.all.each do |user|
          letter_scheme = TwistyPuzzles::BernhardLetterScheme.new
          user.modes.each do |mode|
            mode.inputs.each do |input|
              next unless input.input_representation.is_a?(TwistyPuzzles::PartCycle)
              next unless mode.mode_type.letter_scheme_mode

              input.update(input_representation: mode.mode_type.maybe_apply_letter_scheme(letter_scheme, input.input_representation))
            end
          end
        end
      end
    end
  end
end
