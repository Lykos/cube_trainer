class AuthOverrides::SessionsController < DeviseTokenAuth::SessionsController
  before_action :configure_permitted_parameters

  # POST /api/auth/sign_in
  def create
    super
  end

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in, keys: [:name_or_email, :password])
  end
end
