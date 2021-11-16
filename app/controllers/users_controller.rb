# frozen_string_literal: true

# Controller for users.
class UsersController < ApplicationController
  prepend_before_action :set_user, only: %i[show update destroy]
  before_action :set_confirm_email_user, only: %i[confirm_email]
  before_action :authenticate_admin!, only: [:index]
  before_action :authenticate_admin!, only: %i[create update] if: -> do
    params[:user] && params[:user][:admin]
  end

  # The actions `create`, `confirm_email` and `name_or_email_exists?` are needed for signup and
  # hence we can't require the user to already be signed in.
  # For index, we have the `check_authorized_as_admin` check instead and because these ones
  # wouldn't work, we turn them off.
  skip_before_action :check_current_user_can_read,
                     only: %i[create name_or_email_exists? index confirm_email]
  skip_before_action :check_current_user_can_write,
                     only: %i[create name_or_email_exists? index confirm_email]
  skip_before_action :authenticate_user!, only: %i[create name_or_email_exists? confirm_email]

  # GET /api/username_or_email_exists
  def name_or_email_exists?
    username_or_email = params[:username_or_email]
    exists = User.exists?(name: username_or_email) || User.exists?(email: username_or_email)
    render json: exists, status: :ok
  end

  # POST /api/confirm_email
  def confirm_email
    @user.confirm_email
  end

  # GET /api/users
  def index
    render json: User.all, status: :ok
  end

  # GET /api/users/1
  def show
    render json: @user, status: :ok
  end

  # POST /api/users
  def create
    @user = User.new(user_params)

    if !@user.valid?
      render json: @user.errors, status: :bad_request
    elsif @user.save
      render json: @user, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/users/1
  def update
    if @user.update(user_params)
      render json: @user, status: :ok
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/users/1
  def destroy
    if @user.destroy
      head :no_content
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  private

  def check_authorized_as_admin_if_setting_admin
    unless params[:user] &&
           params[:user][:admin] &&
           params[:user][:admin] != 'false' &&
           !admin_logged_in?
      return
    end

    # TODO: Make this work with Angular
    render 'application/hackerman', status: :unauthorized
  end

  def set_user
    head :not_found unless (@user = User.find_by(id: params[:id]))
  end

  def set_confirm_email_user
    head :not_found unless (@user = User.find_by(confirm_token: params[:token]))
  end

  def owner
    @user
  end

  # Only allow a list of trusted parameters through.
  def user_params
    if admin_logged_in?
      params.require(:user).permit(:name, :password, :password_confirmation, :email, :admin)
    else
      # Note that we already check that `:admin` gets filtered out earlier.
      # This is an additional safety net.
      params.require(:user).permit(:name, :password, :password_confirmation, :email)
    end
  end
end
