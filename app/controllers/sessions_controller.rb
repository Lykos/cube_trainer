class SessionsController < ApplicationController
  skip_before_action :authorized, only: [:new, :create]

  # GET /login
  def new
    respond_to do |format|
      format.html { render 'application/empty' }
    end
  end

  # GET /welcome
  def welcome
    respond_to do |format|
      format.html { render 'application/empty' }
    end
  end

  # POST /login
  def create
   @user = User.find_by(name: params[:username])
   if @user && @user.authenticate(params[:password])
     session[:user_id] = @user.id
     head :ok
   else
     head :unauthorized     
   end
  end
  
  # POST /logout
  def logout
    session.delete(:user_id)
    head :ok
  end
end
