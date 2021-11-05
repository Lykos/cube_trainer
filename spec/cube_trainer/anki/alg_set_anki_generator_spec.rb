# frozen_string_literal: true

require 'csv'
require 'cube_trainer/anki/alg_set_anki_generator'
require 'twisty_puzzles'
require 'tempfile'
require 'ostruct'

CONSTANT_IMAGE = 'some image'

class ConstantFetcher
  def get(_url)
    CONSTANT_IMAGE
  end
end

class TrueChecker
  def valid?(_image)
    true
  end
end

describe Anki::AlgSetAnkiGenerator do
  after { FileUtils.remove_entry(output_dir) }

  let(:output_dir) { Dir.mktmpdir('images') }
  let(:output) { Tempfile.new(['deck', '.tsv']) }
  let(:base_options) do
    options = OpenStruct.new
    options.color_scheme = TwistyPuzzles::ColorScheme::WCA
    options.output_dir = output_dir
    options.output = output.path
    options.cube_size = 3
    options
  end
  let(:external_options) do
    options = base_options
    options.input = 'testdata/alg_set.tsv'
    options.name_column = 0
    options.alg_column = 1
    options
  end
  let(:external_options_with_alternative_algs) do
    options = base_options
    options.input = 'testdata/alg_set_with_alternative_algs.tsv'
    options.name_column = 0
    options.alg_column = 1
    options.alternative_algs_column = 2
    options
  end
  let(:internal_options) do
    options = base_options
    options.alg_set = 'cp'
    options
  end
  let(:generator) { described_class.new(options, fetcher: ConstantFetcher.new, checker: TrueChecker.new) }
  let(:deck) { CSV.read(output, col_sep: "\t") }

  shared_examples 'an image storer' do |image_files|
    shared_examples 'a single image storer' do |image_file|
      it 'puts the fetched content into the image files' do
        generator.generate

        expect(File.read(File.join(output_dir, image_file))).to eq(CONSTANT_IMAGE)
      end
    end

    it 'generates a directory with image files' do
      generator.generate

      expect(Dir.entries(output_dir).sort).to eq((['.', '..'] + image_files).sort)
    end

    image_files.each do |image_file|
      it_behaves_like 'a single image storer', image_file
    end
  end

  context 'when using an external alg set' do
    let(:options) { external_options }

    it 'generates an alg set anki deck' do
      generator.generate

      expect(deck).to contain_exactly(
        ['asdf', 'U', "<img src='alg_asdf.jpg'/>"],
        ['uio', 'F', "<img src='alg_uio.jpg'/>"]
      )
    end

    it_behaves_like 'an image storer', ['alg_asdf.jpg', 'alg_uio.jpg']
  end

  context 'when using an external alg set with alternative algs' do
    let(:options) { external_options_with_alternative_algs }

    it 'generates an alg set anki deck' do
      generator.generate

      expect(deck).to contain_exactly(
        ['asdf', 'U', 'U2 U2 U,U U U U U', "<img src='alg_asdf.jpg'/>"],
        ['uio', 'F', 'F2 F2 F', "<img src='alg_uio.jpg'/>"]
      )
    end

    it_behaves_like 'an image storer', ['alg_asdf.jpg', 'alg_uio.jpg']
  end

  context 'when using an internal alg set' do
    let(:options) { internal_options }

    it 'generates an alg set anki deck' do
      generator.generate

      expect(deck).to contain_exactly(
        ['Y', "F R U' R' U' R U R' F' R U R' U' R' F R F'", '', "<img src='alg_Y.jpg'/>"],
        ['auf skip + Ja', "R' U L' U2 R U' R' U2 R L", '', "<img src='alg_auf_skip_+_Ja.jpg'/>"],
        ['U + Ja', "U R' U L' U2 R U' R' U2 R L", '', "<img src='alg_U_+_Ja.jpg'/>"],
        ['U2 + Ja', "U2 R' U L' U2 R U' R' U2 R L", '', "<img src='alg_U2_+_Ja.jpg'/>"],
        ["U' + Ja", "U' R' U L' U2 R U' R' U2 R L", '', "<img src='alg_U-_+_Ja.jpg'/>"],
        ['solved', '', '', "<img src='alg_solved.jpg'/>"]
      )
    end

    it_behaves_like 'an image storer', [
      'alg_Y.jpg',
      'alg_auf_skip_+_Ja.jpg',
      'alg_U_+_Ja.jpg',
      'alg_U2_+_Ja.jpg',
      'alg_U-_+_Ja.jpg',
      'alg_solved.jpg'
    ]
  end
end
