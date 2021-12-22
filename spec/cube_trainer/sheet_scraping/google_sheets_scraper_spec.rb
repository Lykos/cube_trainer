# frozen_string_literal: true

require 'cube_trainer/sheet_scraping/google_sheets_scraper'
require 'rails_helper'

describe CubeTrainer::SheetScraping::GoogleSheetsScraper do
  include_context 'with alg spreadsheet'
  include_context 'with google sheets get_spreadsheet API response'
  include_context 'with google sheets get_spreadsheet_values API response'

  let(:spreadsheet_id) { alg_spreadsheet.spreadsheet_id }
  let(:range) { 'UF!A1:Z1000' }

  let(:authorizer) do
    authorizer = double('authorizer')
    expect(authorizer).to receive(:fetch_access_token!)
    authorizer
  end
  
  let(:credentials_factory) do
    factory = double('credentials_factory')
    expect(factory).to receive(:make_creds).with(hash_including(scope: 'https://www.googleapis.com/auth/spreadsheets.readonly')) { authorizer }
    factory
  end

  let(:sheets_service) do
    factory = double('sheets_service')
    expect(factory).to receive(:'authorization=').with(authorizer)
    allow(factory).to receive(:get_spreadsheet).with(spreadsheet_id) { get_spreadsheet_response }
    allow(factory).to receive(:get_spreadsheet_values).with(spreadsheet_id, range) { get_spreadsheet_values_response }
    factory
  end

  let(:sheets_service_factory) do
    factory = double('sheets_service_factory')
    expect(factory).to receive(:new) { sheets_service }
    factory
  end

  it 'parses a sheet correctly' do
    alg_spreadsheet
    described_class.new(
      credentials_factory: credentials_factory,
      sheets_service_factory: sheets_service_factory
    ).run

    expect(AlgSet.all.count).to eq(1)
    expect(AlgSet.first.alg_spreadsheet).to eq(alg_spreadsheet)
  end
end
