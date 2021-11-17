# frozen_string_literal: true

# Controller for users.
class UsersController < ApplicationController
  # The action `name_or_email_exists?` is needed for signup and
  # hence we can't require the user to already be signed in.
  skip_before_action :authenticate_user!, only: %i[create name_or_email_exists?]

  # GET /api/username_or_email_exists
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
  # TODO: Likely delete this as devise-auth-token handles this now.
  def create
    @user = User.new(user_params)

    if !@user.valid?
      render json: @user.errors, status: :bad_request
    elsif @user.save
      render json: @user, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/user
  # TODO: Likely delete this as devise-auth-token handles this now.
  def update
    if current_user.update(user_params)
      render json: current_user, status: :ok
    else
      render json: current_user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/user
  # TODO: Likely delete this as devise-auth-token handles this now.
  def destroy
    if current_user.destroy
      head :no_content
    else
      render json: current_user.errors, status: :unprocessable_entity
    end
  end

  private

  # Only allow a list of trusted parameters through.
  def user_params
    params.require(:user).permit(:name, :password, :password_confirmation, :email)
  end
end
