# frozen_string_literal: true

# Controller for messages that the user received.
class MessagesController < ApplicationController
  before_action :set_message, only: %i[show update destroy]

  # GET /api/messages/count_unread
  def count_unread
    render json: current_user.messages.where(read: false).count
  end

  # GET /api/messages
  def index
    render json: current_user.messages
  end

  # GET /api/messages/1
  def show
    render json: @message
  end

  # PATCH/PUT /api/messages/1
  def update
    if @message.update(message_params)
      render json: @message, status: :ok
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/messages/1
  def destroy
    if @message.destroy
      head :no_content
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  private

  def set_message
    head :not_found unless (@message = current_user.messages.find_by(id: params[:id]))
  end

  # Only allow a list of trusted parameters through.
  def message_params
    params.require(:message).permit(:read)
  end
end
