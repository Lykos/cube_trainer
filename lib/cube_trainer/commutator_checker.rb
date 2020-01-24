require 'cube_trainer/cube_state'
require 'cube_trainer/commutator'
require 'cube_trainer/algorithm'
require 'cube_trainer/color_scheme'
require 'cube_trainer/cube_print_helper'

module CubeTrainer
  
  class CommutatorChecker

    include CubePrintHelper
    
    def initialize(part_type:, buffer:, piece_name:, color_scheme:, cube_size:, verbose: false, incarnation_index: 0)
      raise ArgumentError unless part_type.is_a?(Class) && part_type.ancestors.include?(Part)
      raise ArgumentError unless buffer.class == part_type
      raise ArgumentError, "Unsuitable cube size #{cube_size}." unless cube_size.is_a?(Integer) && cube_size > 0
      raise ColorScheme unless color_scheme.is_a?(ColorScheme)
      @part_type = part_type
      @buffer = buffer
      @piece_name = piece_name
      @color_scheme = color_scheme
      @cube_size = cube_size
      @verbose = verbose
      @incarnation_index = incarnation_index
      @alg_cube_state = @color_scheme.solved_cube_state(@cube_size)
      @cycle_cube_state = @color_scheme.solved_cube_state(@cube_size)
      @total_algs = 0
      @broken_algs = 0
      @unfixable_algs = 0
    end

    attr_reader :total_algs, :broken_algs, :unfixable_algs

    def construct_cycle(parts)
      [@buffer] + parts
    end

    def move_modifications(move)
      [move, move.inverse].uniq
    end

    def permutation_modifications(alg)
      if alg.length <= 3
        alg.moves.permutation.collect { |p| Algorithm.new(p) }
      else
        [alg]
      end
    end

    def alg_modifications(alg)
      perms = permutation_modifications(alg)
      a, *as = alg.moves.map { |m| move_modifications(m) }
      perms + a.product(*as).map { |ms| Algorithm.new(ms) }
    end

    def comm_part_modifications(algorithm)
      if algorithm.moves.length == 1
        alg_modifications(algorithm)
      elsif algorithm.moves.length == 3
        a, b = algorithm.moves[0], algorithm.moves[1]
        move_modifications(algorithm.moves[1]).flat_map do |m|
          if a != b.inverse 
            lol = [Algorithm.new([a, m, a.inverse]), Algorithm.new([a.inverse, m, a])]
            if a != b
              lol += [Algorithm.new([b, m, b.inverse]), Algorithm.new([b.inverse, m, b])]
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

    def potential_fixes(commutator)
      if commutator.is_a?(SetupCommutator) then
        alg_modifications(commutator.setup).product(potential_fixes(commutator.inner_commutator)).map { |setup, comm| SetupCommutator.new(setup, comm) }
      elsif commutator.is_a?(PureCommutator)
        comm_part_modifications(commutator.first_part).product(comm_part_modifications(commutator.second_part)).flat_map { |a, b| [PureCommutator.new(a, b), PureCommutator.new(b, a)].uniq }
      elsif commutator.is_a?(FakeCommutator)
        alg_modifications(commutator.algorithm).map { |a| FakeCommutator.new(a) }
      else
        raise ArgumentError
      end
    end

    def find_fix(commutator)
      potential_fixes(commutator).each do |fix|
        fix_alg = fix.algorithm
        return fix_alg if fix_alg.apply_temporarily_to(@alg_cube_state) { @cycle_cube_state == @alg_cube_state }
      end
      nil
    end

    def check_alg(row_description, letter_pair, parts, commutator)
      # Apply alg and cycle
      cycle = construct_cycle(parts)
      @cycle_cube_state.apply_piece_cycle(cycle, @incarnation_index)
      alg = commutator.algorithm
      @total_algs += 1

      # compare
      correct = alg.apply_temporarily_to(@alg_cube_state) { @cycle_cube_state == @alg_cube_state }
      fix_found = false
      unless correct
        puts "Algorithm for #{@piece_name} #{letter_pair} at #{row_description} #{commutator} doesn't do what it's expected to do." if @verbose
        @broken_algs += 1

        # Try to find a fix, but only if verbose is enabled, otherwise that is pointless.
        if @verbose
          if fix = find_fix(commutator)
            fix_found = true
            puts "Found fix #{fix}."
          else
            @unfixable_algs += 1
            puts "Couldn't find a fix for this alg."
            puts "actual"
            puts alg.apply_temporarily_to(@alg_cube_state) { cube_string(@alg_cube_state, :color) }
            puts "expected"
            puts cube_string(@cycle_cube_state, :color)
          end
        end
      end

      # cleanup
      @cycle_cube_state.apply_piece_cycle(cycle.reverse)
      raise "Cleanup failed" unless @alg_cube_state == @cycle_cube_state

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
