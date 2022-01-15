# frozen_string_literal: true

# Controller for downloading a dump of all the information we have for a user.
class DumpsController < ApplicationController
  # GET /api/dump
  def show
    render json: current_user, serializer: UserDumpSerializer, status: :ok
  end
end
