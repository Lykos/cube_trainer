class SessionsController < ApplicationController
  skip_before_action :check_authorized, only: [:new, :create]

  # GET /login
  def new
    render 'application/empty'
  end

  # GET /welcome
  def welcome
    render 'application/empty'
  end

  # POST /login
  def create
   @user = User.find_by(name: params[:username])
   if @user && @user.authenticate(params[:password])
     session[:user_id] = @user.id
     head :no_content
   else
     head :unauthorized     
   end
  end
  
  # POST /logout
  def logout
    session.delete(:user_id)
    head :no_content
  end
end
