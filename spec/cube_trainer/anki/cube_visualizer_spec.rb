# frozen_string_literal: true

require 'cube_trainer/anki/cube_visualizer'
require 'twisty_puzzles'

URL = 'http://cube.rider.biz/visualcube.php?fmt=jpg&sch=yellow%2Cgreen%2Cred%2Cwhite%2Cblue%2Corange&pzl=3&fd=uuuuuuuuurrrrrrrrrfffffffffdddddddddlllllllllbbbbbbbbb'
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
    data.exclude?('invalid')
  end
end

class HashCache
  def initialize
    @hash = {}
  end

  def fetch(key)
    r = @hash[key]
    return r if r

    r = yield
    @hash[key] = r
    r
  end
end

describe Anki::CubeVisualizer do
  include TwistyPuzzles

  let(:color_scheme) { TwistyPuzzles::ColorScheme::BERNHARD }
  let(:cube_size) { 3 }
  let(:cube_state) { color_scheme.solved_cube_state(cube_size) }
  let(:fetcher) { FakeFetcher.new(IMAGE) }
  let(:cache) { HashCache.new }
  let(:retries) { 0 }
  let(:checker) { FakeChecker.new }
  let(:fmt) { :jpg }

  it 'throws an exception for missing color scheme' do
    expect { described_class.new(fetcher: fetcher, cache: cache, retries: retries, checker: checker) }.to raise_error(ArgumentError)
  end

  it 'throws an exception for an argument of the wrong type' do
    expect { described_class.new(fetcher: fetcher, cache: cache, retries: retries, checker: checker, fmt: fmt, sch: color_scheme, size: 0.0) }.to raise_error(TypeError)
  end

  it 'throws an exception for an argument outside of the valid range' do
    expect { described_class.new(fetcher: fetcher, cache: cache, retries: retries, checker: checker, fmt: fmt, sch: color_scheme, size: -1) }.to raise_error(ArgumentError)
  end

  it 'constructs a url for minimal settings' do
    expect(described_class.new(fetcher: fetcher, cache: cache, retries: retries, checker: checker, fmt: fmt, sch: color_scheme).uri(cube_state).to_s).to eq('http://cube.rider.biz/visualcube.php?fmt=jpg&sch=yellow%2Cgreen%2Cred%2Cwhite%2Cblue%2Corange&pzl=3&fd=uuuuuuuuurrrrrrrrrfffffffffdddddddddlllllllllbbbbbbbbb')
  end

  it 'constructs a url for a cube with transparent parts' do
    cube_state[TwistyPuzzles::Coordinate.from_indices(TwistyPuzzles::Face::U, 3, 0, 0)] = :transparent
    cube_state[TwistyPuzzles::Coordinate.from_indices(TwistyPuzzles::Face::F, 3, 0, 1)] = :transparent
    cube_state[TwistyPuzzles::Coordinate.from_indices(TwistyPuzzles::Face::R, 3, 0, 2)] = :transparent
    cube_state[TwistyPuzzles::Coordinate.from_indices(TwistyPuzzles::Face::L, 3, 1, 0)] = :transparent
    cube_state[TwistyPuzzles::Coordinate.from_indices(TwistyPuzzles::Face::B, 3, 1, 1)] = :transparent
    cube_state[TwistyPuzzles::Coordinate.from_indices(TwistyPuzzles::Face::D, 3, 1, 2)] = :transparent
    expect(described_class.new(fetcher: fetcher, cache: cache, retries: retries, checker: checker, fmt: fmt, sch: color_scheme).uri(cube_state).to_s).to eq('http://cube.rider.biz/visualcube.php?fmt=jpg&sch=yellow%2Cgreen%2Cred%2Cwhite%2Cblue%2Corange&pzl=3&fd=uuuuuuuutrrtrrrrrrftfffffffdddtdddddllllltlllbbbbtbbbb')
  end

  it 'constructs a url for a cube with unknown parts' do
    cube_state[TwistyPuzzles::Coordinate.from_indices(TwistyPuzzles::Face::U, 3, 0, 0)] = :unknown
    cube_state[TwistyPuzzles::Coordinate.from_indices(TwistyPuzzles::Face::F, 3, 0, 1)] = :unknown
    cube_state[TwistyPuzzles::Coordinate.from_indices(TwistyPuzzles::Face::R, 3, 0, 2)] = :unknown
    cube_state[TwistyPuzzles::Coordinate.from_indices(TwistyPuzzles::Face::L, 3, 1, 0)] = :unknown
    cube_state[TwistyPuzzles::Coordinate.from_indices(TwistyPuzzles::Face::B, 3, 1, 1)] = :unknown
    cube_state[TwistyPuzzles::Coordinate.from_indices(TwistyPuzzles::Face::D, 3, 1, 2)] = :unknown
    expect(described_class.new(fetcher: fetcher, cache: cache, retries: retries, checker: checker, fmt: fmt, sch: color_scheme).uri(cube_state).to_s).to eq('http://cube.rider.biz/visualcube.php?fmt=jpg&sch=yellow%2Cgreen%2Cred%2Cwhite%2Cblue%2Corange&pzl=3&fd=uuuuuuuunrrnrrrrrrfnfffffffdddndddddlllllnlllbbbbnbbbb')
  end

  it 'constructs a url for a cube with oriented parts' do
    cube_state[TwistyPuzzles::Coordinate.from_indices(TwistyPuzzles::Face::U, 3, 0, 0)] = :oriented
    cube_state[TwistyPuzzles::Coordinate.from_indices(TwistyPuzzles::Face::F, 3, 0, 1)] = :oriented
    cube_state[TwistyPuzzles::Coordinate.from_indices(TwistyPuzzles::Face::R, 3, 0, 2)] = :oriented
    cube_state[TwistyPuzzles::Coordinate.from_indices(TwistyPuzzles::Face::L, 3, 1, 0)] = :oriented
    cube_state[TwistyPuzzles::Coordinate.from_indices(TwistyPuzzles::Face::B, 3, 1, 1)] = :oriented
    cube_state[TwistyPuzzles::Coordinate.from_indices(TwistyPuzzles::Face::D, 3, 1, 2)] = :oriented
    expect(described_class.new(fetcher: fetcher, cache: cache, retries: retries, checker: checker, fmt: fmt, sch: color_scheme).uri(cube_state).to_s).to eq('http://cube.rider.biz/visualcube.php?fmt=jpg&sch=yellow%2Cgreen%2Cred%2Cwhite%2Cblue%2Corange&pzl=3&fd=uuuuuuuuorrorrrrrrfofffffffdddodddddlllllolllbbbbobbbb')
  end

  it 'constructs a url for all settings' do
    expect(
      described_class.new(
        fetcher: fetcher,
        cache: cache,
        retries: retries,
        checker: checker,
        fmt: fmt,
        size: 100,
        view: :plain,
        stage: Anki::StageMask.new(:coll, TwistyPuzzles::Algorithm.move(TwistyPuzzles::Rotation.new(TwistyPuzzles::Face::U, TwistyPuzzles::CubeDirection::FORWARD))),
        sch: color_scheme,
        bg: :black,
        cc: :white,
        co: 40,
        fo: 50,
        dist: 35
      ).uri(cube_state).to_s
    ).to eq('http://cube.rider.biz/visualcube.php?fmt=jpg&size=100&view=plain&stage=coll-y&sch=yellow%2Cgreen%2Cred%2Cwhite%2Cblue%2Corange&bg=black&cc=white&co=40&fo=50&dist=35&pzl=3&fd=uuuuuuuuurrrrrrrrrfffffffffdddddddddlllllllllbbbbbbbbb')
  end

  it 'fetches an image' do
    expect(described_class.new(fetcher: fetcher, cache: cache, retries: retries, checker: checker, fmt: fmt, sch: color_scheme).fetch(cube_state)).to eq(IMAGE)
  end

  it 'fails if the fetched image is invalid' do
    expect { described_class.new(fetcher: FakeFetcher.new('invalid'), cache: cache, retries: retries, checker: checker, fmt: fmt, sch: color_scheme).fetch(cube_state) }.to raise_error(RuntimeError)
  end

  it 'fetches an image without cache' do
    expect(described_class.new(fetcher: fetcher, retries: retries, checker: checker, fmt: fmt, sch: color_scheme).fetch(cube_state)).to eq(IMAGE)
  end

  it 'fetches an image and then cache it' do
    expect(described_class.new(fetcher: fetcher, cache: cache, retries: retries, checker: checker, fmt: fmt, sch: color_scheme).fetch(cube_state)).to eq(IMAGE)
    expect(described_class.new(fetcher: FailFetcher.new, cache: cache, retries: retries, fmt: fmt, sch: color_scheme).fetch(cube_state)).to eq(IMAGE)
  end

  it 'parses a stage mask correctly' do
    mask = Anki::StageMask.parse('coll-x2')
    expect(mask.base_mask).to eq(:coll)
    expect(mask.rotations).to eq(TwistyPuzzles::Algorithm.move(TwistyPuzzles::Rotation.new(TwistyPuzzles::Face::R, TwistyPuzzles::CubeDirection::DOUBLE)))
  end
end
