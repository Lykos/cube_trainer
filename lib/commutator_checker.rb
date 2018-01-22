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
      [@piece_type::BUFFER] + letter_pair.letters.map { |l| @piece_type.for_letter(l) }
    end

    def move_modifications(move)
      [move, move.invert].uniq
    end

    def alg_modifications(alg)
      perms = alg.moves.permutation.collect { |p| Algorithm.new(p) }
      a, *as = alg.moves.map { |m| move_modifications(m) }
      perms + a.product(*as).map { |ms| Algorithm.new(ms) }
    end

    def comm_part_modifications(algorithm)
      if algorithm.moves.length == 1
        alg_modifications(algorithm)
      elsif algorithm.moves.length == 3
        a, b = algorithm.moves[0], algorithm.moves[1]
        move_modifications(algorithm.moves[1]).flat_map do |m|
          if a != b.invert 
            lol = [Algorithm.new([a, m, a.invert]), Algorithm.new([a.invert, m, a])]
            if a != b
              lol += [Algorithm.new([b, m, b.invert]), Algorithm.new([b.invert, m, b])]
            end
            lol
          else
            [Algorithm.new([a, m, b]), Algorithm.new([b, m, a])]
          end
        end
      else
        [algorithm]
      end
    end

    def fixes(commutator)
      if commutator.is_a?(SetupCommutator) then
        alg_modifications(commutator.setup).product(fixes(commutator.pure_commutator)).map { |setup, comm| SetupCommutator.new(setup, comm) }
      elsif commutator.is_a?(PureCommutator)
        comm_part_modifications(commutator.first_part).product(comm_part_modifications(commutator.second_part)).flat_map { |a, b| [PureCommutator.new(a, b), PureCommutator.new(b, a)].uniq }
      else
        raise ArgumentError
      end
    end

    def check_alg(row_description, letter_pair, commutator)
      # Apply alg and cycle
      cycle = construct_cycle(letter_pair)
      @cycle_cube_state.apply_piece_cycle(cycle, @incarnation_index)
      alg = commutator.algorithm
      alg.apply_to(@alg_cube_state)

      # compare
      correct = @cycle_cube_state == @alg_cube_state
      fix_found = false
      unless correct
        puts "Algorithm for #{@piece_name} #{letter_pair} at #{row_description} #{commutator} doesn't do what it's expected to do."

        # Try to find a fix.
        fix_comm = nil
        alg.invert.apply_to(@alg_cube_state)
        fixes(commutator).each do |fix|
          fix_alg = fix.algorithm
          fix_alg.apply_to(@alg_cube_state)
          fix_found ||= @cycle_cube_state == @alg_cube_state
          fix_alg.invert.apply_to(@alg_cube_state)
          fix_comm = fix if fix_found
          break if fix_found
        end
        alg.apply_to(@alg_cube_state)
        if fix_found
          puts "Found fix #{fix_comm}."
        else
          puts "Couldn't find a fix for this alg."
          puts "actual"
          puts @alg_cube_state
          puts "expected"
          puts @cycle_cube_state
        end
      end

      # cleanup
      @cycle_cube_state.apply_piece_cycle(cycle.reverse)
      alg.invert.apply_to(@alg_cube_state)
      raise unless @alg_cube_state == @cycle_cube_state

      if correct
        :correct
      elsif fix_found
        :fix_found
      else
        :unfixable
      end
    end
  end
end
