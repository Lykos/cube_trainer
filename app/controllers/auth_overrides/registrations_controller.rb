# frozen_string_literal: true

module AuthOverrides
  # Our controller for the registration flow of device-token-auth.
  class RegistrationsController < DeviseTokenAuth::RegistrationsController
    before_action :configure_permitted_parameters

    # POST /api/auth

    # PUT/PATCH /api/auth

    private

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(
        :sign_up,
        keys: %i[name email password password_confirmation]
      )
      devise_parameter_sanitizer.permit(
        :account_update,
        keys: %i[
          name email password current_password
          password_confirmation
        ]
      )
    end
  end
end
