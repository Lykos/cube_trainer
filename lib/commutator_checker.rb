require 'cube_state'
require 'commutator'

module CubeTrainer
  class CommutatorChecker
    def initialize(piece_type, piece_name, cube_size, incarnation_index=0)
      raise ArgumentError unless piece_type.is_a?(Class) && piece_type.ancestors.include?(Part)
      raise ArgumentError, "Unsuitable cube size #{cube_size}." unless cube_size.is_a?(Integer) && cube_size > 0
      @piece_type = piece_type
      @piece_name = piece_name
      @cube_size = cube_size
      @incarnation_index = incarnation_index
    end

    def cycle(letter_pair)
      [@piece_type::BUFFER] + letter_pair.letters.collect { |l| @piece_type.for_letter(l) }
    end

    def new_cube_state
      CubeState.solved(@cube_size)
    end
    
    def check_alg(letter_pair, commutator)
      return true unless letter_pair == LetterPair.new(['k', 'p'])
      desired_state = new_cube_state
      desired_state.apply_piece_cycle(cycle(letter_pair), @incarnation_index)
      actual_state = new_cube_state
      commutator.algorithm.apply_to(actual_state)
      correct = actual_state == desired_state
      unless correct
        puts "Algorithm for #{@piece_name} #{letter_pair} #{commutator.algorithm} doesn't do what it's expected to do."
        puts "actual"
        puts actual_state
        puts "expected"
        puts desired_state
      end
      correct
    end
  end
end
