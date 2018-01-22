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
      @alg_cube_state = CubeState.solved(@cube_size)
      @cycle_cube_state = CubeState.solved(@cube_size)
    end

    def construct_cycle(letter_pair)
      [@piece_type::BUFFER] + letter_pair.letters.collect { |l| @piece_type.for_letter(l) }
    end

    def check_alg(letter_pair, commutator)
      # Apply alg and cycle
      cycle = construct_cycle(letter_pair)
      @cycle_cube_state.apply_piece_cycle(cycle, @incarnation_index)
      alg = commutator.algorithm
      alg.apply_to(@alg_cube_state)

      # compare
      correct = @cycle_cube_state == @alg_cube_state
      unless correct
        puts "Algorithm for #{@piece_name} #{letter_pair} #{commutator.algorithm} doesn't do what it's expected to do."
        puts "actual"
        puts @alg_cube_state
        puts "expected"
        puts @cycle_cube_state
      end

      # cleanup
      @cycle_cube_state.apply_piece_cycle(cycle.reverse)
      alg.invert.apply_to(@alg_cube_state)
      raise unless @alg_cube_state == @cycle_cube_state

      correct
    end
  end
end
