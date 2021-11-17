class AuthOverrides::RegistrationsController < DeviseTokenAuth::RegistrationsController
  before_action :configure_permitted_parameters

  # POST /api/auth
  def create
    byebug
    super
  end

  # PUT/PATCH /api/auth
  def update
    super
  end
  
  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i(name email password password_confirmation))
    devise_parameter_sanitizer.permit(:account_update, keys: %i(name email password password_confirmation))
  end
end
