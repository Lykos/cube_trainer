# frozen_string_literal: true

module AuthOverrides
  # Our controller for the sign-in flow of device-token-auth.
  class SessionsController < DeviseTokenAuth::SessionsController
    before_action :configure_permitted_parameters

    # POST /api/auth/sign_in

    private

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_in, keys: %i[name_or_email password])
    end
  end
end
