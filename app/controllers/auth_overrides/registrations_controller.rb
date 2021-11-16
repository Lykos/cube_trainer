class AuthOverrides::RegistrationsController < DeviseTokenAuth::RegistrationsController
  before_action :configure_permitted_parameters

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i(name email password password_confirmation))
    devise_parameter_sanitizer.permit(:account_update, keys: %i(name email password password_confirmation))
  end
end
