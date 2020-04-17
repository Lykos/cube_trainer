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
   @user = User.find_by(name: params[:username]) || User.find_by(email: params[:email])
   if @user && @user.authenticate(params[:password])
     session[:user_id] = @user.id
     render json: @user.to_simple, status: :ok
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
