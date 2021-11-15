# frozen_string_literal: true

# Mailer that sends a confirmation email after a user signs up.
class SignupMailer < ApplicationMailer
  def signup_confirmation
    @user = params[:user]
    # TODO: Figure out a way around this uglyness.
    uri_builder = Rails.env.production? ? URI::HTTPS : URI::HTTP
    @confirm_url =
      uri_builder.build(
        { path: "/confirm_email/#{@user.confirm_token}" }
                                  .reverse_merge!(default_url_options)
      )
    # TODO: Use "name < email@domain.tld >" once we figure out escaping.
    mail(to: @user.email, subject: 'CubeTrainer Registration Confirmation')
  end
end
