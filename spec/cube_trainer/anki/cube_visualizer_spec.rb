# frozen_string_literal: true

require 'cube_trainer/anki/cube_visualizer'
require 'cube_trainer/color_scheme'
require 'cube_trainer/core/algorithm'
require 'cube_trainer/core/coordinate'
require 'cube_trainer/core/cube'
require 'cube_trainer/core/direction'
require 'cube_trainer/core/move'
require 'cube_trainer/core/parser'

URL = 'http://cube.crider.co.uk/visualcube.php?fmt=jpg&sch=yellow%2Cgreen%2Cred%2Cwhite%2Cblue%2Corange&pzl=3&fd=uuuuuuuuurrrrrrrrrfffffffffdddddddddlllllllllbbbbbbbbb'
IMAGE = 'some image'

class FakeFetcher
  def initialize(image)
    @image = image
  end

  def get(url)
    raise "Unknown url '#{url}'" if url.to_s != URL

    @image
  end
end

class FailFetcher
  def get(_key)
    raise
  end
end

class FakeChecker
  def valid?(data)
    !data.include?('invalid')
  end
end

describe Anki::CubeVisualizer do
  include Core

  let(:color_scheme) { ColorScheme::BERNHARD }
  let(:cube_size) { 3 }
  let(:cube_state) { color_scheme.solved_cube_state(cube_size) }
  let(:fetcher) { FakeFetcher.new(IMAGE) }
  let(:cache) { {} }
  let(:retries) { 0 }
  let(:checker) { FakeChecker.new }
  let(:fmt) { :jpg }

  it 'should throw an exception for missing color scheme' do
    expect { Anki::CubeVisualizer.new(fetcher: fetcher, cache: cache, retries: retries, checker: checker) }.to raise_error ArgumentError
  end

  it 'should throw an exception for an argument of the wrong type' do
    expect { Anki::CubeVisualizer.new(fetcher: fetcher, cache: cache, retries: retries, checker: checker, fmt: fmt, sch: color_scheme, size: 0.0) }.to raise_error TypeError
  end

  it 'should throw an exception for an argument outside of the valid range' do
    expect { Anki::CubeVisualizer.new(fetcher: fetcher, cache: cache, retries: retries, checker: checker, fmt: fmt, sch: color_scheme, size: -1) }.to raise_error ArgumentError
  end

  it 'should construct a url for minimal settings' do
    expect(Anki::CubeVisualizer.new(fetcher: fetcher, cache: cache, retries: retries, checker: checker, fmt: fmt, sch: color_scheme).uri(cube_state).to_s).to be == 'http://cube.crider.co.uk/visualcube.php?fmt=jpg&sch=yellow%2Cgreen%2Cred%2Cwhite%2Cblue%2Corange&pzl=3&fd=uuuuuuuuurrrrrrrrrfffffffffdddddddddlllllllllbbbbbbbbb'
  end

  it 'should construct a url for a cube with transparent parts' do
    cube_state[Core::Coordinate.from_indices(Core::Face::U, 3, 0, 0)] = :transparent
    cube_state[Core::Coordinate.from_indices(Core::Face::F, 3, 0, 1)] = :transparent
    cube_state[Core::Coordinate.from_indices(Core::Face::R, 3, 0, 2)] = :transparent
    cube_state[Core::Coordinate.from_indices(Core::Face::L, 3, 1, 0)] = :transparent
    cube_state[Core::Coordinate.from_indices(Core::Face::B, 3, 1, 1)] = :transparent
    cube_state[Core::Coordinate.from_indices(Core::Face::D, 3, 1, 2)] = :transparent
    expect(Anki::CubeVisualizer.new(fetcher: fetcher, cache: cache, retries: retries, checker: checker, fmt: fmt, sch: color_scheme).uri(cube_state).to_s).to be == 'http://cube.crider.co.uk/visualcube.php?fmt=jpg&sch=yellow%2Cgreen%2Cred%2Cwhite%2Cblue%2Corange&pzl=3&fd=uuuuuuuutrrtrrrrrrftfffffffdddtdddddllllltlllbbbbtbbbb'
  end

  it 'should construct a url for a cube with unknown parts' do
    cube_state[Core::Coordinate.from_indices(Core::Face::U, 3, 0, 0)] = :unknown
    cube_state[Core::Coordinate.from_indices(Core::Face::F, 3, 0, 1)] = :unknown
    cube_state[Core::Coordinate.from_indices(Core::Face::R, 3, 0, 2)] = :unknown
    cube_state[Core::Coordinate.from_indices(Core::Face::L, 3, 1, 0)] = :unknown
    cube_state[Core::Coordinate.from_indices(Core::Face::B, 3, 1, 1)] = :unknown
    cube_state[Core::Coordinate.from_indices(Core::Face::D, 3, 1, 2)] = :unknown
    expect(Anki::CubeVisualizer.new(fetcher: fetcher, cache: cache, retries: retries, checker: checker, fmt: fmt, sch: color_scheme).uri(cube_state).to_s).to be == 'http://cube.crider.co.uk/visualcube.php?fmt=jpg&sch=yellow%2Cgreen%2Cred%2Cwhite%2Cblue%2Corange&pzl=3&fd=uuuuuuuunrrnrrrrrrfnfffffffdddndddddlllllnlllbbbbnbbbb'
  end

  it 'should construct a url for a cube with oriented parts' do
    cube_state[Core::Coordinate.from_indices(Core::Face::U, 3, 0, 0)] = :oriented
    cube_state[Core::Coordinate.from_indices(Core::Face::F, 3, 0, 1)] = :oriented
    cube_state[Core::Coordinate.from_indices(Core::Face::R, 3, 0, 2)] = :oriented
    cube_state[Core::Coordinate.from_indices(Core::Face::L, 3, 1, 0)] = :oriented
    cube_state[Core::Coordinate.from_indices(Core::Face::B, 3, 1, 1)] = :oriented
    cube_state[Core::Coordinate.from_indices(Core::Face::D, 3, 1, 2)] = :oriented
    expect(Anki::CubeVisualizer.new(fetcher: fetcher, cache: cache, retries: retries, checker: checker, fmt: fmt, sch: color_scheme).uri(cube_state).to_s).to be == 'http://cube.crider.co.uk/visualcube.php?fmt=jpg&sch=yellow%2Cgreen%2Cred%2Cwhite%2Cblue%2Corange&pzl=3&fd=uuuuuuuuorrorrrrrrfofffffffdddodddddlllllolllbbbbobbbb'
  end

  it 'should construct a url for all settings' do
    expect(Anki::CubeVisualizer.new(
      fetcher: fetcher,
      cache: cache,
      retries: retries,
      checker: checker,
      fmt: fmt,
      size: 100,
      view: :plain,
      stage: Anki::CubeVisualizer::StageMask.new(:coll, Core::Algorithm.move(Core::Rotation.new(Core::Face::U, Core::CubeDirection::FORWARD))),
      sch: color_scheme,
      bg: :black,
      cc: :white,
      co: 40,
      fo: 50,
      dist: 35
    ).uri(cube_state).to_s).to be == 'http://cube.crider.co.uk/visualcube.php?fmt=jpg&size=100&view=plain&stage=coll-y&sch=yellow%2Cgreen%2Cred%2Cwhite%2Cblue%2Corange&bg=black&cc=white&co=40&fo=50&dist=35&pzl=3&fd=uuuuuuuuurrrrrrrrrfffffffffdddddddddlllllllllbbbbbbbbb'
  end

  it 'should fetch an image' do
    expect(Anki::CubeVisualizer.new(fetcher: fetcher, cache: cache, retries: retries, checker: checker, fmt: fmt, sch: color_scheme).fetch(cube_state)).to be == IMAGE
  end

  it 'should fail if the fetched image is invalid' do
    expect { Anki::CubeVisualizer.new(fetcher: FakeFetcher.new('invalid'), cache: cache, retries: retries, checker: checker, fmt: fmt, sch: color_scheme).fetch(cube_state) }.to raise_error RuntimeError
  end

  it 'should fetch an image without cache' do
    expect(Anki::CubeVisualizer.new(fetcher: fetcher, retries: retries, checker: checker, fmt: fmt, sch: color_scheme).fetch(cube_state)).to be == IMAGE
  end

  it 'should fetch an image and then cache it' do
    expect(Anki::CubeVisualizer.new(fetcher: fetcher, cache: cache, retries: retries, checker: checker, fmt: fmt, sch: color_scheme).fetch(cube_state)).to be == IMAGE
    expect(Anki::CubeVisualizer.new(fetcher: FailFetcher.new, cache: cache, retries: retries, fmt: fmt, sch: color_scheme).fetch(cube_state)).to be == IMAGE
  end

  it 'should parse a stage mask correctly' do
    mask = Anki::CubeVisualizer::StageMask.parse('coll-x2')
    expect(mask.base_mask).to be == :coll
    expect(mask.rotations).to be == Core::Algorithm.move(Core::Rotation.new(Core::Face::R, Core::CubeDirection::DOUBLE))
  end
end
