# frozen_string_literal: true

# Base class for all controllers. Handles things like checking for login.
class ApplicationController < ActionController::Base
  before_action :check_authorized

  def current_user
    User.find_by(id: session[:user_id])
  end

  def logged_in?
    !current_user.nil?
  end

  def admin_logged_in?
    current_user&.admin?
  end

  def check_authorized
    render json: {}, status: :unauthorized unless logged_in?
  end

  def check_authorized_as_admin
    render json: {}, status: :unauthorized unless admin_logged_in?
  end

  # Checks that the user is the current user.
  # In order to not allow reverse engineering, we have to return not_found in all such cases.
  def check_current_user_owns
    head :not_found unless owner == current_user || admin_logged_in?
  end
end
