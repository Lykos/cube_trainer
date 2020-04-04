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

  def admin_logged_in?       
    current_user&.admin?
  end

  def authorized
    render status: :unauthorized unless logged_in?
  end

  def authorized_as_admin
    render status: :unauthorized unless admin_logged_in?
  end

  # Checks that the user is the current user.
  def check_owner_is_current_user
    redirect_to '/welcome', notice: "Can't modify other user." unless get_owner == current_user || admin_logged_in?
  end
end
