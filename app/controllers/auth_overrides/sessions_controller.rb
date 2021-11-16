class AuthOverrides::SessionsController < DeviseTokenAuth::SessionsController
  before_action :configure_permitted_parameters

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in, keys: %i(name_or_email password))
  end
end
