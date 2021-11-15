# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SignupMailer, type: :mailer do
  let(:user) do
    # It's important that we create a new user here.
    User.find_by(name: 'mailer_user')&.destroy
    User.create!(name: 'mailer_user', admin_confirmed: true, password: 'password', email: 'mailer_user@cubetrainer.org')
  end

  let(:mailer) { described_class.with(user: user) }

  it 'generates a confirmation email' do
    email = mailer.signup_confirmation

    assert_emails 1 do
      email.deliver_now
    end

    expect(email.to).to eq([user.email])
    expect(email.from).to eq(['no-reply@cubetrainer.org'])
    expect(email.text_part.body.to_s).to include(user.name)
    expect(email.html_part.body.to_s).to include(user.name)
  end
end
