# frozen_string_literal: true

# Controller that handles sessions and login.
class SessionsController < ApplicationController
  # For logging in, we don't check whether the user is already logged in.
  skip_before_action :authenticate_user!, only: %i[create]
  skip_before_action :check_current_user_can_read, only: %i[create]
  skip_before_action :check_current_user_can_write, only: %i[create]

  # POST /login
  def create
    username_or_email = params[:username_or_email]
    @user = User.find_by(name: username_or_email) || User.find_by(email: username_or_email)
    if @user&.authenticate(params[:password]) && @user&.confirmed
      session[:user_id] = @user.id
      render json: @user.to_simple, status: :ok
    else
      head(:unauthorized)
    end
  end

  # POST /logout
  def logout
    session.delete(:user_id)
    head :no_content
  end

  def owner
    current_user
  end
end
