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
        ['', 'UB', 'UR', 'UL'],
        ['UB', '', '[R2 U : [S, R2]]', "[L2 U' : [L2, S']]"],
        ['UR', '[R2 U : [R2, S]]', '', "[M2 : [U/M']]"],
        ['UL', "[L2 U' : [L2, S']]", "[M2 : [U/M']]"],
        [],
        ['', 'One of the UL UR algs needs to be fixed']
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
    described_class.new(
      credentials_factory: credentials_factory,
      sheets_service_factory: sheets_service_factory
    ).run

    expect(sheets_service).to have_received(:'authorization=').with(authorizer)
    expect(authorizer).to have_received(:fetch_access_token!)
    expect(AlgSet.all.count).to eq(1)
    expect(AlgSet.first.alg_spreadsheet).to eq(alg_spreadsheet)
  end
end
