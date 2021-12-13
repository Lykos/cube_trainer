# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Message, type: :model do
  include_context 'with user abc'

  it 'should broadcast a message after creation' do
    expect {
      user.messages.create(title: 'hi')
    }.to broadcast_to(MessageChannel.broadcasting_for(user)).with(title: 'hi')
  end
end
