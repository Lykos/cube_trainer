# frozen_string_literal: true

# Controller for users.
class UsersController < ApplicationController
  before_action :set_user, only: %i[show update destroy]
  before_action :check_authorized_as_admin, only: [:index]
  before_action :check_authorized_as_admin_if_setting_admin, only: %i[create update]
  before_action :check_current_user_owns, only: %i[show update destroy]
  skip_before_action :check_authorized, only: %i[new create name_or_email_exists?]

  # GET /username_or_email_exists
  def name_or_email_exists?
    username_or_email = params[:username_or_email]
    exists = User.exists?(name: username_or_email) || User.exists?(email: username_or_email)
    render json: exists, status: :ok
  end

  # GET /users
  # GET /users.json
  def index
    respond_to do |format|
      format.html { render 'application/cube_trainer' }
      format.json { render json: User.all, status: :ok }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    respond_to do |format|
      format.html { render 'application/cube_trainer' }
      format.json { render json: @user, status: :ok }
    end
  end

  # GET /users/new
  def new
    render 'application/cube_trainer'
  end

  # GET /users/1/edit
  def edit
    render 'application/cube_trainer'
  end

  # POST /users
  # POST /users.json
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

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    if @user.update(user_params)
      render json: @user, status: :ok
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
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

    render 'application/hackerman', status: :unauthorized
  end

  def set_user
    head :not_found unless (@user = User.find_by(id: params[:id]))
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
