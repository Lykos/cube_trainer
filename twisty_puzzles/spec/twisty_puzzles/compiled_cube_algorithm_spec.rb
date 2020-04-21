# frozen_string_literal: true

require 'twisty_puzzles/color_scheme'
require 'twisty_puzzles/algorithm'
require 'twisty_puzzles/compiled_cube_algorithm'
require 'twisty_puzzles/cube'
require 'twisty_puzzles/cube_print_helper'
require 'rantly'
require 'rantly/rspec_extensions'
require 'rantly/shrinks'

shared_examples 'compiled_cube_algorithm' do |cube_size|
  
  include CubePrintHelper

  let(:color_scheme) { TwistyPuzzles::ColorScheme::BERNHARD }
  let(:cube_state) { color_scheme.solved_cube_state(cube_size) }
  let(:compile_then_transform_cube_state) { cube_state.dup }
  let(:transform_then_compile_cube_state) { cube_state.dup }

  it 'goes back to the old state if we apply an algorithm and then the inverse' do
    property_of do
      Rantly { cube_algorithm(cube_size) }
    end.check do |a|
      modified_cube_state = cube_state.dup
      a.compiled_for_cube(cube_size).apply_to(modified_cube_state)
      a.inverse.compiled_for_cube(cube_size).apply_to(modified_cube_state)
      expect(modified_cube_state).to eq_puzzle_state(cube_state)
    end
  end

  it 'behaves the same if we mirror then compile or if we compile then mirror' do
    property_of do
      Rantly { [cube_algorithm(cube_size), face] }
    end.check do |a, f|
      a.compiled_for_cube(cube_size).mirror(f).apply_to(compile_then_transform_cube_state)
      a.mirror(f).compiled_for_cube(cube_size).apply_to(transform_then_compile_cube_state)
      expect(compile_then_transform_cube_state).to eq_puzzle_state(transform_then_compile_cube_state)
    end
  end

  it 'behaves the same if we rotate then compile or if we compile then rotate' do
    property_of do
      Rantly { [cube_algorithm(cube_size), rotation] }
    end.check do |a, r|
      a.compiled_for_cube(cube_size).rotate_by(r).apply_to(compile_then_transform_cube_state)
      a.rotate_by(r).compiled_for_cube(cube_size).apply_to(transform_then_compile_cube_state)
      expect(compile_then_transform_cube_state).to eq_puzzle_state(transform_then_compile_cube_state)
    end
  end

  it 'behaves the same if we invert then compile or if we compile then invert' do
    property_of do
      Rantly { cube_algorithm(cube_size) }
    end.check do |a|
      a.compiled_for_cube(cube_size).inverse.apply_to(compile_then_transform_cube_state)
      a.inverse.compiled_for_cube(cube_size).apply_to(transform_then_compile_cube_state)
      expect(compile_then_transform_cube_state).to eq_puzzle_state(transform_then_compile_cube_state)
    end
  end

  it 'behaves the same if we concatenate then compile or if we compile then concatenate' do
    property_of do
      Rantly { [cube_algorithm(cube_size), cube_algorithm(cube_size)] }
    end.check do |a, b|
      (a.compiled_for_cube(cube_size) + b.compiled_for_cube(cube_size)).apply_to(compile_then_transform_cube_state)
      (a + b).compiled_for_cube(cube_size).apply_to(transform_then_compile_cube_state)
      expect(compile_then_transform_cube_state).to eq_puzzle_state(transform_then_compile_cube_state)
    end
  end
end

describe CompiledCubeAlgorithm do
  context 'when the cube size is 3' do
    it_behaves_like 'compiled_cube_algorithm', 3
  end

  context 'when the cube size is 4' do
    it_behaves_like 'compiled_cube_algorithm', 4
  end

  context 'when the cube size is 5' do
    it_behaves_like 'compiled_cube_algorithm', 5
  end
end
