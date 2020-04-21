# frozen_string_literal: true

require 'csv'
require 'cube_trainer/anki/skewb_layer_anki_generator'
require 'twisty_puzzles'
require 'twisty_puzzles'
require 'tempfile'
require 'ostruct'

BASE_DECK = [
  ['case description', 'main alg', 'center_transformations', 'top_corner_transformations', 'alternative algs', 'name', 'tags'],
  ['', '', '', 'UFL stays, URF stays, ULB stays, UBR stays', '', '', '0_mover 4_solved'],
  ['FUR → DRB', "UBR'", 'U → R → B', 'UFL stays, BUL → URF, BDR → ULB, BRU → UBR', '', 'E', '1_mover 3_solved'],
  ['LUF → DFR, URF → DRB', "URF' UBR'", 'U → F → B', 'RUB → UFL, BUL → URF, BDR → ULB, DFR → UBR', '', 'MB', '2_mover 2_adjacent_solved'],
  ['BRU → DFR, RFU → DRB', "URF UBR'", 'U ↔ B, F ↔ R', 'FRD → UFL, BUL → URF, BDR → ULB, LUF → UBR', '', 'RJ', '2_mover 2_adjacent_solved'],
  ['LFD → DRB, BUL → DLF', "UFL' UBR'", 'U → L → F → R → B', 'FLU → UFL, RFU → URF, BDR → ULB, BRU → UBR', '', 'NQ', '2_mover 2_opposite_solved'],
  ['ULB → DRB, RFU → DLF', "UFL UBR'", 'U → F → L → R → B', 'LUF → UFL, DLF → URF, BDR → ULB, BRU → UBR', '', 'CJ', '2_mover 2_opposite_solved'],
  ['FUR → DRB, RUB → DBL', "ULB' UBR'", 'R → B → L', 'LDB → UFL, ULB → URF, BDR → ULB, UFL → UBR', '', 'EI', '2_mover 2_adjacent_solved'],
  ['FUR → DRB, FLU → DBL', "ULB UBR'", 'U ↔ L, R ↔ B', 'BRU → UFL, LBU → URF, BDR → ULB, LDB → UBR', '', 'EG', '2_mover 2_adjacent_solved']
].map(&:freeze).freeze

def delete_columns(deck, columns)
  deck.map! do |row|
    row.reject.with_index { |_e, i| columns.include?(i) }
  end
end

RSpec::Matchers.define(:be_modified_deck) do |column, expected_elements, wildcard_columns = []|
  raise ArgumentError unless BASE_DECK.length == expected_elements.length
  raise ArgumentError if wildcard_columns.include?(column)

  expected =
    BASE_DECK.zip(expected_elements).map do |row, element|
      dupped = row.dup
      dupped[column] = element
      dupped
    end
  delete_columns(expected, wildcard_columns)

  match do |actual|
    dupped_actual = actual.dup
    delete_columns(dupped_actual, wildcard_columns)
    dupped_actual == expected
  end

  failure_message do |actual|
    dupped_actual = actual.dup
    delete_columns(dupped_actual, wildcard_columns)
    actual_elements = dupped_actual.map { |row| row[column] }
    if expected_elements != actual_elements
      "expected that changed column #{column} with elements #{actual_elements.inspect} would equal #{expected_elements.inspect}"
    else
      "expected that #{dupped_actual.inspect} would equal #{expected.inspect}"
    end
  end
end

describe Anki::SkewbLayerAnkiGenerator do
  let(:output) { Tempfile.new(['deck', '.tsv']) }
  let(:base_options) do
    options = OpenStruct.new
    options.color_scheme = ColorScheme::WCA
    options.output = output.path
    options.depth = 2
    options.letter_scheme = BernhardLetterScheme.new
    options
  end
  let(:options) { base_options }
  let(:generator) { described_class.new(options) }
  let(:deck) { CSV.read(output, col_sep: "\t") }

  it 'generates the right deck' do
    generator.run

    expect(deck).to eq(BASE_DECK)
  end

  context 'when layer_corners_as_letters is turned on' do
    let(:options) do
      options = base_options
      options.layer_corners_as_letters = true
      options
    end

    it 'uses letters for layer corners' do
      generator.run

      expect(deck).to be_modified_deck(
        0, [
          'case description',
          '',
          'E → V',
          'M → U, B → V',
          'R → U, J → V',
          'N → V, Q → W',
          'C → V, J → W',
          'E → V, I → X',
          'E → V, G → X'
        ]
      )
    end

    context 'when there is a name_file' do
      let(:name_file) { 'testdata/name_file.tsv' }
      let(:options) do
        options = base_options
        options.layer_corners_as_letters = true
        options.name_file = name_file
        options
      end

      it 'uses letters for layer corners' do
        generator.run

        expect(deck).to be_modified_deck(
          0, [
            'case description',
            '',
            'E → V',
            'M → U, B → V',
            'R → U, J → V',
            'N → V, Q → W',
            'C → V, J → W',
            'E → V, I → X',
            'E → V, G → X'
          ],
          [5]
        )
      end

      it 'uses transformed names' do
        generator.run

        expect(deck).to be_modified_deck(
          5, [
            'name',
            '',
            'elektro',
            'miriam barner',
            'raj',
            'naqter',
            'cuji',
            'elfin',
            'egg'
          ],
          [0]
        )
      end
    end
  end

  context 'when top_corners_as_letters is turned on' do
    let(:options) do
      options = base_options
      options.top_corners_as_letters = true
      options
    end

    it 'uses letters for layer corners' do
      generator.run

      expect(deck).to be_modified_deck(
        3, [
          'top_corner_transformations',
          'A stays, B stays, C stays, D stays',
          'A stays, Q → B, T → C, R → D',
          'I → A, Q → B, T → C, U → D',
          'F → A, Q → B, T → C, M → D',
          'G → A, J → B, T → C, R → D',
          'M → A, W → B, T → C, R → D',
          'P → A, C → B, T → C, A → D',
          'R → A, O → B, T → C, P → D'
        ]
      )
    end
  end
end
