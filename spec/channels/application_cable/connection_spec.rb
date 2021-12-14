# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationCable::Connection, type: :channel do
  include_context 'with user abc'
  include_context 'with headers'

  it 'successfully connects' do
    auth_data = user.create_new_auth_token
    connect "/cable?uid=#{auth_data['uid']}&client=#{auth_data['client']}&access_token=#{auth_data['access-token']}"
    expect(connection.current_user).to eq(user)
  end

  it 'rejects connection when not logged in' do
    expect { connect '/cable', headers: headers }.to have_rejected_connection
  end
end
