class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]
  before_action :check_authorized_as_admin, only: [:index]
  before_action :check_owner_is_current_user, only: [:show, :update, :destroy]
  skip_before_action :check_authorized, only: [:new, :create]

  # GET /users
  # GET /users.json
  def index
    respond_to do |format|
      format.html { render 'application/empty' }
      format.json { render json: User.all, status: :ok }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    respond_to do |format|
      format.html { render 'application/empty' }
      format.json { render json: @user, status: :ok }
    end      
  end

  # GET /users/new
  def new
    render 'application/empty'
  end

  # GET /users/1/edit
  def edit
    render 'application/empty'
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    if @user.save
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

  def set_user
    head :not_found unless @user = User.find_by(id: params[:id])
  end

  def get_owner
    @user
  end

  # Only allow a list of trusted parameters through.
  def user_params
    if admin_logged_in?
      params.require(:user).permit(:name, :password, :password_confirmation, :admin)
    else
      params.require(:user).permit(:name, :password, :password_confirmation)
    end
  end
end
