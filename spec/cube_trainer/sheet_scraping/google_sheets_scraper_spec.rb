# frozen_string_literal: true

require 'googleauth'
require 'google/apis/sheets_v4'
require 'cube_trainer/sheet_scraping/google_sheets_scraper'
require 'rails_helper'

describe CubeTrainer::SheetScraping::GoogleSheetsScraper do
  include_context 'with alg spreadsheet'

  let(:get_spreadsheet_response) do
    # We define our own versions because the proper ones are hard to create.
    stub_const('Spreadsheet', Struct.new(:sheets))
    stub_const('Sheet', Struct.new(:properties))
    stub_const('Properties', Struct.new(:title, :grid_properties))
    stub_const('GridProperties', Struct.new(:row_count, :column_count))

    Spreadsheet.new(
      [
        Sheet.new(
          Properties.new(
            'UF',
            GridProperties.new(1000, 26)
          )
        )
      ]
    )
  end

  let(:get_spreadsheet_values_response) do
    # We define our own versions because the proper ones are hard to create.
    stub_const('SpreadsheetValues', Struct.new(:values)) # rubocop:disable Lint/StructNewOverride

    SpreadsheetValues.new(
      [
        ['',   'UB',                 'UR',               'UL',                 'DF'],
        ['UB', '',                   '[R2 U : [S, R2]]', "[L2 U' : [S', L2]]", "[M', U2]"],
        ['UR', '[R2 U : [R2, S]]',   '',                 "[M2 : [U'/M]]",       '(U R2 f2 R2) * 2'],
        ['UL', "[L2 U' : [L2, S']]", '[M2 : [U/M]]',     '',                    '(R2 f2 R2 U) * 2'],
        ['DF', "[U2, M']",           '[',                'R U F L',             'R U F L'],
        ['',   'random alg cell', 'R U F L'],
        ['',   'the alg in the UL row and DF column is in the wrong direction'],
        ['',   'the DF row algs are wrong except for UB']
      ]
    )
  end

  let(:spreadsheet_id) { alg_spreadsheet.spreadsheet_id }
  let(:range) { 'UF!A1:Z1000' }

  let(:authorizer) do
    authorizer = instance_double(Google::Auth::ServiceAccountCredentials, 'authorizer')
    allow(authorizer).to receive(:fetch_access_token!)
    authorizer
  end

  let(:credentials_factory) do
    factory = class_double(Google::Auth::ServiceAccountCredentials, 'credentials_factory')
    allow(factory).to receive(:make_creds).with(hash_including(scope: 'https://www.googleapis.com/auth/spreadsheets.readonly')) { authorizer }
    factory
  end

  let(:sheets_service) do
    factory = instance_double(Google::Apis::SheetsV4::SheetsService, 'sheets_service')
    allow(factory).to receive(:'authorization=').with(authorizer)
    allow(factory).to receive(:get_spreadsheet).with(spreadsheet_id) { get_spreadsheet_response }
    allow(factory).to receive(:get_spreadsheet_values).with(spreadsheet_id, range) { get_spreadsheet_values_response }
    factory
  end

  let(:sheets_service_factory) do
    factory = class_double(Google::Apis::SheetsV4::SheetsService, 'sheets_service_factory')
    allow(factory).to receive(:new) { sheets_service }
    factory
  end

  it 'parses a sheet correctly' do
    alg_spreadsheet
    counters = described_class.new(
      credentials_factory: credentials_factory,
      sheets_service_factory: sheets_service_factory
    ).run[0]

    expect(counters[:new_algs]).to eq(10)
    expect(counters[:updated_algs]).to eq(0)
    expect(counters[:confirmed_algs]).to eq(0)
    expect(counters[:correct_algs]).to eq(9)
    expect(counters[:fixed_algs]).to eq(1)
    expect(counters[:unfixable_algs]).to eq(1)
    expect(counters[:unparseable_algs]).to eq(1)

    expect(sheets_service).to have_received(:'authorization=').with(authorizer)
    expect(authorizer).to have_received(:fetch_access_token!)

    expect(AlgSet.all.count).to eq(1)
    expect(AlgSet.first.alg_spreadsheet).to eq(alg_spreadsheet)
    expect(AlgSet.first.algs.count).to eq(10)
  end

  it 'updates an existing sheet correctly' do
    # Simulate a previous run
    alg_spreadsheet
    scraper = described_class.new(
      credentials_factory: credentials_factory,
      sheets_service_factory: sheets_service_factory
    )
    scraper.run

    # Change one alg cell to a different alg.
    get_spreadsheet_values_response.values[4][1] = "U2 M' U2 M"
    counters = scraper.run[0]

    expect(counters[:new_algs]).to eq(0)
    expect(counters[:updated_algs]).to eq(1)
    expect(counters[:confirmed_algs]).to eq(9)

    expect(sheets_service).to have_received(:'authorization=').with(authorizer)
    expect(authorizer).to have_received(:fetch_access_token!).twice

    expect(AlgSet.all.count).to eq(1)
    expect(AlgSet.first.alg_spreadsheet).to eq(alg_spreadsheet)
    expect(AlgSet.first.algs.count).to eq(10)
  end
end
