class SessionsController < ApplicationController
  skip_before_action :authorized, only: [:new, :create, :welcome]

  def new
  end

  def create
   @user = User.find_by(name: params[:username])
   if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      redirect_to '/welcome'
   else
      redirect_to '/login', alert: 'Authentication failed'
   end
  end

  def login
  end

  def logout
    session.delete(:user_id)
    redirect_to '/welcome'
  end

  def welcome
  end
end
