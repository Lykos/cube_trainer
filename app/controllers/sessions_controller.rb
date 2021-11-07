# frozen_string_literal: true

# Controller that handles sessions and login.
class SessionsController < ApplicationController
  skip_before_action :check_authorized, only: %i[new create]

  # GET /login
  def new
    render 'application/cube_trainer'
  end

  # GET /welcome
  def welcome
    render 'application/cube_trainer'
  end

  # POST /login
  def create
    username_or_email = params[:username_or_email]
    @user = User.find_by(name: username_or_email) || User.find_by(email: username_or_email)
    if @user&.authenticate(params[:password]) && @user&.admin_confirmed
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
end
