# frozen_string_literal: true

require 'twisty_puzzles'
require 'cube_trainer/wca/export_parser'
require 'cube_trainer/wca/stats_extractor'
require 'tempfile'

describe WCA::ExportParser do
  include TwistyPuzzles

  before(:all) do
    filename = Tempfile.new(['WCA_export_example', '.tsv.zip'])
    Zip::File.open(filename, Zip::File::CREATE) do |zipfile|
      Dir['testdata/WCA_export_example/*'].each do |input_file|
        zipfile.add(File.basename(input_file), input_file)
      end
    end
    @parser = described_class.parse(filename)
  end

  let(:parser) { @parser }
  let(:extractor) { WCA::StatsExtractor.new(parser) }

  it 'reads the scrambles of a WCA export' do
    expect(parser.scrambles).to eq(
      [{
        scrambleid: 657_918,
        competitionid: 'BerlinKubusProjekt2017',
        eventid: '222',
        roundtypeid: :'1',
        groupid: 'A',
        isextra: false,
        scramblenum: 1,
        scramble: parse_algorithm("U2 R' U2 R U' R U F' U' R U")
      }]
    )
  end

  it 'reads the results of a WCA export' do
    # TODO: Improve this
    expect(parser.results.first[:personid]).to eq('2016BROD01')
  end

  it 'reads the countries of a WCA export' do
    expect(parser.countries).to eq(
      {
        'Germany' => { # rubocop:disable Style/StringHashKeys
          id: 'Germany',
          name: 'Germany',
          continentid: '_Europe',
          iso2: 'DE'
        }
      }
    )
  end

  it 'reads the continents of a WCA export' do
    expect(parser.continents).to eq(
      {
        '_Europe' => { # rubocop:disable Style/StringHashKeys
          id: '_Europe',
          name: 'Europe',
          recordname: 'ER',
          latitude: 58_299_984,
          longitude: 23_049_300,
          zoom: 3
        }
      }
    )
  end

  it 'figures out whether someone nemesizes someone' do
    expect(extractor.nemesis?('2016BROD01', '2017BROD01')).to be(true)
  end

  it 'figures out whether someone does not nemesize someone' do
    expect(extractor.nemesis?('2017BROD01', '2016BROD01')).to be(false)
  end

  it 'finds nemeses if they are empty' do
    expect(extractor.nemeses('2016BROD01')).to be_empty
  end

  it 'finds nemeses if one exists' do
    expect(extractor.nemeses('2017BROD01')).to contain_exactly('2016BROD01')
  end
end
