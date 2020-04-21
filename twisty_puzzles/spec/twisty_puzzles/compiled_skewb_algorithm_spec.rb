# frozen_string_literal: true

require 'twisty_puzzles/color_scheme'
require 'twisty_puzzles/algorithm'
require 'twisty_puzzles/compiled_skewb_algorithm'
require 'twisty_puzzles/cube'
require 'twisty_puzzles/cube_print_helper'
require 'rantly'
require 'rantly/rspec_extensions'
require 'rantly/shrinks'

describe CompiledCubeAlgorithm do
  
  include CubePrintHelper

  let(:color_scheme) { ColorScheme::BERNHARD }
  let(:skewb_state) { color_scheme.solved_skewb_state }
  let(:compile_then_transform_skewb_state) { skewb_state.dup }
  let(:transform_then_compile_skewb_state) { skewb_state.dup }

  it 'goes back to the old state if we apply an algorithm and then the inverse' do
    property_of do
      Rantly { skewb_algorithm }
    end.check do |a|
      modified_skewb_state = skewb_state.dup
      a.compiled_for_skewb.apply_to(modified_skewb_state)
      a.inverse.compiled_for_skewb.apply_to(modified_skewb_state)
      expect(modified_skewb_state).to eq_puzzle_state(skewb_state)
    end
  end

  it 'behaves the same if we mirror then compile or if we compile then mirror' do
    property_of do
      Rantly { [skewb_algorithm, face] }
    end.check do |a, f|
      a.compiled_for_skewb.mirror(f).apply_to(compile_then_transform_skewb_state)
      a.mirror(f).compiled_for_skewb.apply_to(transform_then_compile_skewb_state)
      expect(compile_then_transform_skewb_state).to eq_puzzle_state(transform_then_compile_skewb_state)
    end
  end

  it 'behaves the same if we rotate then compile or if we compile then rotate' do
    property_of do
      Rantly { [skewb_algorithm, rotation] }
    end.check do |a, r|
      a.compiled_for_skewb.rotate_by(r).apply_to(compile_then_transform_skewb_state)
      a.rotate_by(r).compiled_for_skewb.apply_to(transform_then_compile_skewb_state)
      expect(compile_then_transform_skewb_state).to eq_puzzle_state(transform_then_compile_skewb_state)
    end
  end

  it 'behaves the same if we invert then compile or if we compile then invert' do
    property_of do
      Rantly { skewb_algorithm }
    end.check do |a|
      a.compiled_for_skewb.inverse.apply_to(compile_then_transform_skewb_state)
      a.inverse.compiled_for_skewb.apply_to(transform_then_compile_skewb_state)
      expect(compile_then_transform_skewb_state).to eq_puzzle_state(transform_then_compile_skewb_state)
    end
  end

  it 'behaves the same if we concatenate then compile or if we compile then concatenate' do
    property_of do
      Rantly { [skewb_algorithm, skewb_algorithm] }
    end.check do |a, b|
      (a.compiled_for_skewb + b.compiled_for_skewb).apply_to(compile_then_transform_skewb_state)
      (a + b).compiled_for_skewb.apply_to(transform_then_compile_skewb_state)
      expect(compile_then_transform_skewb_state).to eq_puzzle_state(transform_then_compile_skewb_state)
    end
  end
end
