class MessagesController < ApplicationController
  before_action :set_user
  before_action :set_message, only: [:show, :edit, :update, :destroy]
  before_action :check_current_user_owns

  # GET /users/1/messages
  # GET /users/1/messages.json
  def index
    respond_to do |format|
      format.html { render 'application/empty' }
      format.json { render json: current_user.messages }
    end
  end

  # GET /users/1/messages/1
  # GET /users/1/messages/1.json
  def show
    respond_to do |format|
      format.html { render 'application/empty' }
      format.json { render json: @message }
    end
  end

  # GET /users/1/messages/1/edit
  def edit
    render 'application/empty'
  end

  # PATCH/PUT /users/1/messages/1
  # PATCH/PUT /users/1/messages/1.json
  def update
    if @message.update(message_params)
      render json: @message, status: :ok
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1/messages/1
  # DELETE /users/1/messages/1.json
  def destroy
    if @message.destroy
      head :no_content
    else 
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  private

  def set_user
    head :not_found unless @user = User.find_by(id: params[:user_id])
  end

  def set_message
    head :not_found unless @message = @user.messages.find_by(id: params[:id])
  end

  def get_owner
    @user
  end

  # Only allow a list of trusted parameters through.
  def message_params
    params.require(:message).permit(:read)
  end

  # Checks that the user is the current user.
  # Note that this is different from other controllers because not even admin can see the messages.
  # In order to not allow reverse engineering, we have to return not_found in all such cases.
  def check_current_user_owns
    head :not_found unless get_owner == current_user
  end
end
