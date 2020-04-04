class SessionsController < ApplicationController
  skip_before_action :authorized, only: [:new, :create]

  def new
  end

  def create
   @user = User.find_by(name: params[:username])
   if @user && @user.authenticate(params[:password])
     session[:user_id] = @user.id
     render status: :ok
   else
     render status: :unauthorized     
   end
  end
  
  def logout
    session.delete(:user_id)
    render status: :ok
  end
end
