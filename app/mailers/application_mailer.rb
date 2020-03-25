# frozen_string_literal: true

# Mailer for this Rails app.
class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'
end
