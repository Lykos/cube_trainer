require 'rails_helper'

RSpec.describe ApplicationCable::Connection, type: :channel do
  include_context 'with user abc'
  include_context 'with headers'
  include_context 'with user auth headers'

  it "successfully connects" do
    connect '/cable', headers: user_headers
    expect(connection.current_user).to eq(user)
  end

  it 'rejects connection when not logged in' do
    expect { connect '/cable', headers: headers }.to have_rejected_connection
  end
end
