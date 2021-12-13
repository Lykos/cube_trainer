require 'rails_helper'

RSpec.describe MessageChannel, type: :channel do
  include_context 'with user abc'

  it "successfully subscribes" do
    stub_connection current_user: user

    subscribe
    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_for(user)
  end
end
