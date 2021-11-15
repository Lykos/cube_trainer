# frozen_string_literal: true

# Mailer for this Rails app.
class ApplicationMailer < ActionMailer::Base
  default from: 'no-reply@cubetrainer.org'
  layout 'mailer'

  # TODO: Move to configs
  def default_url_options
    if Rails.env.production?
      { host: 'cubetrainer.org' }
    else
      { host: 'localhost', port: 4200 }
    end
  end
end
