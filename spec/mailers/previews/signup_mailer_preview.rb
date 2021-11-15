# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/signup_mailer
class SignupMailerPreview < ActionMailer::Preview
  def signup_confirmation
    User.find_by(name: 'preview_user')&.destroy
    user = User.create!(
      name: 'preview_user', admin_confirmed: true, password: 'password',
      email: 'preview_user@cubetrainer.org'
    )
    SignupMailer.with(user: user).signup_confirmation
  end
end
