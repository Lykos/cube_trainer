# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UnreadMessagesCountChannel, type: :channel do
  include_context 'with user abc'

  it 'successfully subscribes' do
    user.messages.clear
    stub_connection current_user: user

    expect { subscribe }.to broadcast_to(user).with(unread_messages_count: 0)
    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_for(user)
  end
end
