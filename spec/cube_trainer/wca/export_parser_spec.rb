require 'cube_trainer/core/parser'
require 'cube_trainer/wca/export_parser'
require 'tempfile'

describe WCA::ExportParser do
  before(:all) do
    filename = Tempfile.new(['WCA_export_example', '.tsv.zip'])
    Zip::File.open(filename, Zip::File::CREATE) do |zipfile|
      Dir['testdata/WCA_export_example/*'].each do |input_file|
        zipfile.add(File.basename(input_file), input_file)
      end
    end
    @parser = WCA::ExportParser.parse(filename)
  end

  it 'should read the scrambles of a WCA export' do
    expect(@parser.scrambles).to be == [{
                                          scrambleid: 657918,
                                          competitionid: 'BerlinKubusProjekt2017',
                                          eventid: '222',
                                          roundtypeid: :'1',
                                          groupid: 'A',
                                          isextra: false,
                                          scramblenum: 1,
                                          scramble: parse_algorithm("U2 R' U2 R U' R U F' U' R U")
                                        }]
  end

  it 'should read the results of a WCA export' do
    # TODO: Improve this
    expect(@parser.results.first[:personid]).to be == '2016BROD01'
  end

  it 'should read the countries of a WCA export' do
    expect(@parser.countries).to be == {'Germany' => {
                                          id: 'Germany',
                                          name: 'Germany',
                                          continentid: '_Europe',
                                          iso2: 'DE'
                                        }}
  end
  
  it 'should read the continents of a WCA export' do
    expect(@parser.continents).to be == {'_Europe' => {
                                           id: '_Europe',
                                           name: 'Europe',
                                           recordname: 'ER',
                                           latitude: 58299984,
                                           longitude: 23049300,
                                           zoom: 3
                                         }}
  end
  
  it 'should figure out whether someone nemesizes someone' do
    expect(@parser.nemesis?('2016BROD01', '2017BROD01')).to be true
    expect(@parser.nemesis?('2017BROD01', '2016BROD01')).to be false
  end
  
  it 'should find nemeses' do
    expect(@parser.nemeses('2016BROD01')).to be == []
    expect(@parser.nemeses('2017BROD01')).to be == ['2016BROD01']
  end
  
end
