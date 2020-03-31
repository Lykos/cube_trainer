# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authorized
  helper_method :current_user
  helper_method :logged_in?

  def current_user
    User.find_by(id: session[:user_id])
  end

  def logged_in?       
    !current_user.nil?
  end

  def authorized
    redirect_to '/welcome', alert: 'Not logged in' unless logged_in?
  end

  # Checks that the user is the current user.
  def check_owner_is_current_user
    redirect_to '/welcome', alert: "Can't modify other user." unless get_owner == current_user
  end
end
