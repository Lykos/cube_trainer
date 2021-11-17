# frozen_string_literal: true

# Controller for users.
class UsersController < ApplicationController
  # The action `name_or_email_exists?` is needed for signup and
  # hence we can't require the user to already be signed in.
  skip_before_action :authenticate_user!, only: %i[create name_or_email_exists?]

  # GET /api/name_or_email_exists
  def name_or_email_exists?
    username_or_email = params[:username_or_email]
    exists = User.exists?(name: username_or_email) || User.exists?(email: username_or_email)
    render json: exists, status: :ok
  end

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
