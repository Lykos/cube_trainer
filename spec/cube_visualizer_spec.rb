require 'cube_visualizer'
require 'color_scheme'

include CubeTrainer

describe CubeVisualizer do

  let(:color_scheme) { ColorScheme::BERNHARD }
  let(:cube_size) { 3 }
  let(:cube_state) { color_scheme.solved_cube_state(cube_size) }

  it 'should throw an exception for missing color scheme' do
    expect { CubeVisualizer.new }.to raise_error ArgumentError
  end

  it 'should throw an exception for an argument of the wrong type' do
    expect { CubeVisualizer.new(fmt: :svg, sch: color_scheme, size: 0.0) }.to raise_error TypeError
  end

  it 'should throw an exception for an argument outside of the valid range' do
    expect { CubeVisualizer.new(fmt: :svg, sch: color_scheme, size: -1) }.to raise_error ArgumentError
  end

  it 'should construct a url for minimal settings' do
    expect(CubeVisualizer.new(fmt: :svg, sch: color_scheme).uri(cube_state).to_s).to be == 'http://cube.crider.co.uk/visualcube.php?fmt=svg&sch=yellow%2Cgreen%2Cred%2Cwhite%2Cblue%2Corange&pzl=3&fd=UUUUUUUUU+RRRRRRRRR+FFFFFFFFF+DDDDDDDDD+LLLLLLLLL+BBBBBBBBB'
  end
  
  it 'should construct a url for all settings' do
    expect(CubeVisualizer.new(
             fmt: :svg,
             size: 100,
             view: :plain,
             sch: color_scheme,
             bg: :black,
             cc: :white,
             co: 40,
             fo: 50,
             dist: 35
           ).uri(cube_state).to_s).to be == 'http://cube.crider.co.uk/visualcube.php?fmt=svg&size=100&view=plain&sch=yellow%2Cgreen%2Cred%2Cwhite%2Cblue%2Corange&bg=black&cc=white&co=40&fo=50&dist=35&pzl=3&fd=UUUUUUUUU+RRRRRRRRR+FFFFFFFFF+DDDDDDDDD+LLLLLLLLL+BBBBBBBBB'
  end
  
end
