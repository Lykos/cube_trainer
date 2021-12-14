# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Message, type: :model do
  include_context 'with user abc'

  it 'should broadcast a message after creation' do
    expect {
      user.messages.create(title: 'hi')
    }.to broadcast_to(MessageChannel.broadcasting_for(user)).with(title: 'hi')
  end

  it 'should broadcast unread messages count after creation' do
    user.messages.clear
    expect {
      user.messages.create(title: 'hi')
    }.to broadcast_to(UnreadMessagesCountChannel.broadcasting_for(user)).with(unread_messages_count: 1)
  end

  it 'should broadcast unread messages count after being read' do
    user.messages.clear
    message = user.messages.create(title: 'hi')
    expect {
      message.update(read: true)
    }.to broadcast_to(UnreadMessagesCountChannel.broadcasting_for(user)).with(unread_messages_count: 0)
  end
end
