# frozen_string_literal: true

require 'cube_trainer/training/download_state'

module CubeTrainer
  module Training
    class DatabaseSyncer
      def initialize(model)
        @model = model
        @logger = Rails.logger
      end

      def hostname
        @hostname ||= `hostname`.chomp
      end

      def upload!
        uploaded = @model.where("hostname = ? AND (uploaded_at IS NULL OR updated_at > uploaded_at)", hostname).to_a
        logger.info("Uploading #{uploaded.length} records of type #{model.name}.")
        ActiveRecord::Base.connected_to(:global) do
          uploaded.each do |item|
            item.uploaded_at = Time.now
            item.save!
          end
        end
        uploaded.each(&:save!)
      end

      def download!
        download_state = download_state.downloaded_at
        now = Time.now
        downloaded =
          ActiveRecord::Base.connected_to(:global) do
            @model.where("hostname != ? AND uploaded_at > ?", hostname, download_state.downloaded_at).to_a
          end
        logger.info("Inserting #{uploaded.length} downloaded records of type #{model.name}.")
        downloaded.each(&save!)
        download_state.downloaded_at = now
        download_state.save!
      end

      def sync!
        upload!
        download!
      end
    end
  end
end
