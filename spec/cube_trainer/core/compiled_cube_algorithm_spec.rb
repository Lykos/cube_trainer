require 'cube_trainer/color_scheme'
require 'cube_trainer/core/algorithm'
require 'cube_trainer/core/move'
require 'cube_trainer/core/compiled_cube_algorithm'
require 'cube_trainer/core/cube'
require 'cube_trainer/core/cube_print_helper'
require 'rantly'
require 'rantly/rspec_extensions'
require 'rantly/shrinks'

include CubePrintHelper

RSpec.shared_examples 'compiled_cube_algorithm' do |cube_size|

  let(:color_scheme) { ColorScheme::BERNHARD }
  let(:cube_state) { color_scheme.solved_cube_state(cube_size) }
  let(:compile_then_transform_cube_state) { cube_state.dup }
  let(:transform_then_compile_cube_state) { cube_state.dup }

  it 'should go back to the old state if we apply an algorithm and then the inverse' do
    property_of {
      Rantly { cube_algorithm(cube_size) }
    }.check { |a|
      modified_cube_state = cube_state.dup
      a.compiled_for_cube(cube_size).apply_to(modified_cube_state)
      a.inverse.compiled_for_cube(cube_size).apply_to(modified_cube_state)
      expect(modified_cube_state).to be == cube_state
    }
  end

  it 'should behave the same if we mirror then compile or if we compile then mirror' do
    property_of {
      Rantly { [cube_algorithm(cube_size), face] }
    }.check { |a, f|
      a.compiled_for_cube(cube_size).mirror(f).apply_to(compile_then_transform_cube_state)
      a.mirror(f).compiled_for_cube(cube_size).apply_to(transform_then_compile_cube_state)
      expect(compile_then_transform_cube_state).to be == transform_then_compile_cube_state
    }
  end

  it 'should behave the same if we rotate then compile or if we compile then rotate' do
    property_of {
      Rantly { [cube_algorithm(cube_size), rotation] }
    }.check { |a, r|
      a.compiled_for_cube(cube_size).rotate_by(r).apply_to(compile_then_transform_cube_state)
      a.rotate_by(r).compiled_for_cube(cube_size).apply_to(transform_then_compile_cube_state)
      expect(compile_then_transform_cube_state).to be == transform_then_compile_cube_state
    }
  end

  it 'should behave the same if we invert then compile or if we compile then invert' do
    property_of {
      Rantly { cube_algorithm(cube_size) }
    }.check { |a|
      a.compiled_for_cube(cube_size).inverse.apply_to(compile_then_transform_cube_state)
      a.inverse.compiled_for_cube(cube_size).apply_to(transform_then_compile_cube_state)
      expect(compile_then_transform_cube_state).to be == transform_then_compile_cube_state
    }
  end

  it 'should behave the same if we concatenate then compile or if we compile then concatenate' do
    property_of {
      Rantly { [cube_algorithm(cube_size), cube_algorithm(cube_size)] }
    }.check { |a, b|
      (a.compiled_for_cube(cube_size) + b.compiled_for_cube(cube_size)).apply_to(compile_then_transform_cube_state)
      (a + b).compiled_for_cube(cube_size).apply_to(transform_then_compile_cube_state)
      expect(compile_then_transform_cube_state).to be == transform_then_compile_cube_state
    }
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
