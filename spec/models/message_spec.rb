# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Message do
  include_context 'with user abc'

  it 'broadcasts a message after creation' do
    expect do
      user.messages.create(title: 'hi')
    end.to have_broadcasted_to(MessageChannel.broadcasting_for(user)).with(title: 'hi')
  end

  it 'broadcasts unread messages count after creation' do
    user.messages.clear
    expect do
      user.messages.create(title: 'hi')
    end.to have_broadcasted_to(UnreadMessagesCountChannel.broadcasting_for(user)).with(unread_messages_count: 1)
  end

  it 'broadcasts unread messages count after deletion' do
    user.messages.clear
    message = user.messages.create(title: 'hi')
    expect do
      message.destroy
    end.to have_broadcasted_to(UnreadMessagesCountChannel.broadcasting_for(user)).with(unread_messages_count: 0)
  end

  it 'broadcasts unread messages count after being read' do
    user.messages.clear
    message = user.messages.create(title: 'hi')
    expect do
      message.update(read: true)
    end.to have_broadcasted_to(UnreadMessagesCountChannel.broadcasting_for(user)).with(unread_messages_count: 0)
  end
end
