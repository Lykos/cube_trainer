# frozen_string_literal: true

# Controller for users.
class UsersController < ApplicationController
  # TODO: Deprecate
  # GET /api/user
  def show
    render json: current_user, status: :ok
  end

  # POST /api/user
  # Creating new users is handled by auth_overrides/registrations_controller

  # PATCH/PUT /api/user
  # Creating new users is handled by auth_overrides/registrations_controller

  # DELETE /api/user
  # Deleting users is handled by auth_overrides/registrations_controller

  private

  # Only allow a list of trusted parameters through.
  def user_params
    params.require(:user).permit(:name, :password, :password_confirmation, :email)
  end
end
