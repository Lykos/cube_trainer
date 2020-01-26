require 'cube_trainer/anki/cube_visualizer'
require 'cube_trainer/color_scheme'
require 'cube_trainer/algorithm'
require 'cube_trainer/move'

URL = 'http://cube.crider.co.uk/visualcube.php?fmt=svg&sch=yellow%2Cgreen%2Cred%2Cwhite%2Cblue%2Corange&pzl=3&fd=uuuuuuuuurrrrrrrrrfffffffffdddddddddlllllllllbbbbbbbbb'
IMAGE = 'some image'

class FakeFetcher
  def get(url)
    if url.to_s == URL
      IMAGE
    else
      raise "Unknown url '#{url}'"
    end
  end
end

class FailFetcher
  def get(key)
    raise
  end
end

describe CubeVisualizer do

  let(:color_scheme) { ColorScheme::BERNHARD }
  let(:cube_size) { 3 }
  let(:cube_state) { color_scheme.solved_cube_state(cube_size) }
  let(:fetcher) { FakeFetcher.new }
  let(:cache) { {} }

  it 'should throw an exception for missing color scheme' do
    expect { CubeVisualizer.new(fetcher, cache) }.to raise_error ArgumentError
  end

  it 'should throw an exception for an argument of the wrong type' do
    expect { CubeVisualizer.new(fetcher, cache, fmt: :svg, sch: color_scheme, size: 0.0) }.to raise_error TypeError
  end

  it 'should throw an exception for an argument outside of the valid range' do
    expect { CubeVisualizer.new(fetcher, cache, fmt: :svg, sch: color_scheme, size: -1) }.to raise_error ArgumentError
  end

  it 'should construct a url for minimal settings' do
    expect(CubeVisualizer.new(fetcher, cache, fmt: :svg, sch: color_scheme).uri(cube_state).to_s).to be == 'http://cube.crider.co.uk/visualcube.php?fmt=svg&sch=yellow%2Cgreen%2Cred%2Cwhite%2Cblue%2Corange&pzl=3&fd=uuuuuuuuurrrrrrrrrfffffffffdddddddddlllllllllbbbbbbbbb'
  end
  
  it 'should construct a url for a cube with transparent parts' do
    #cube_state[Coordinate.for_]
    expect(CubeVisualizer.new(fetcher, cache, fmt: :svg, sch: color_scheme).uri(cube_state).to_s).to be == 'http://cube.crider.co.uk/visualcube.php?fmt=svg&sch=yellow%2Cgreen%2Cred%2Cwhite%2Cblue%2Corange&pzl=3&fd=uuuuuuuuurrrrrrrrrfffffffffdddddddddlllllllllbbbbbbbbb'
  end
  
  it 'should construct a url for all settings' do
    expect(CubeVisualizer.new(
             fetcher,
             cache,
             fmt: :svg,
             size: 100,
             view: :plain,
             stage: CubeVisualizer::StageMask.new(:coll, Algorithm.move(Rotation.new(Face::U, CubeDirection::FORWARD))),
             sch: color_scheme,
             bg: :black,
             cc: :white,
             co: 40,
             fo: 50,
             dist: 35
           ).uri(cube_state).to_s).to be == 'http://cube.crider.co.uk/visualcube.php?fmt=svg&size=100&view=plain&stage=coll-y&sch=yellow%2Cgreen%2Cred%2Cwhite%2Cblue%2Corange&bg=black&cc=white&co=40&fo=50&dist=35&pzl=3&fd=uuuuuuuuurrrrrrrrrfffffffffdddddddddlllllllllbbbbbbbbb'
  end
  
  it 'should fetch an image' do
    expect(CubeVisualizer.new(fetcher, cache, fmt: :svg, sch: color_scheme).fetch(cube_state)).to be == IMAGE
  end
  
  it 'should fetch an image without cache' do
    expect(CubeVisualizer.new(fetcher, nil, fmt: :svg, sch: color_scheme).fetch(cube_state)).to be == IMAGE
  end
  
  it 'should fetch an image and then cache it' do
    expect(CubeVisualizer.new(fetcher, cache, fmt: :svg, sch: color_scheme).fetch(cube_state)).to be == IMAGE
    expect(CubeVisualizer.new(FailFetcher.new, cache, fmt: :svg, sch: color_scheme).fetch(cube_state)).to be == IMAGE
  end

  it 'should parse a stage mask correctly' do
    mask = CubeVisualizer::StageMask.parse('coll-x2')
    expect(mask.base_mask).to be == :coll
    expect(mask.rotations).to be == Algorithm.move(Rotation.new(Face::R, CubeDirection::DOUBLE))
  end
  
end
