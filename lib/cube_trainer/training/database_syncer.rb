# frozen_string_literal: true

require 'cube_trainer/training/download_state'

module CubeTrainer
  module Training
    class DatabaseSyncer
      def initialize(model)
        @model = model
      end

      def logger
        @logger ||= Rails.logger
      end

      def hostname
        @hostname ||= @model.current_hostname
      end

      def upload!
        uploaded =
          ActiveRecord::Base.connected_to(database: :primary) do
            @model.where('hostname = ? AND (uploaded_at IS NULL OR updated_at > uploaded_at)', hostname).to_a
          end
        puts "Uploading #{uploaded.length} records of type #{@model.name}."
        ActiveRecord::Base.connected_to(database: :global) do
          uploaded.each do |item|
            item.uploaded_at = Time.now
            item.dup.save!
          end
        end
        ActiveRecord::Base.connected_to(database: :primary) do
          uploaded.each { |item| item.save!(touch: false) }
        end
      end

      def download!
        download_state =
          ActiveRecord::Base.connected_to(database: :primary) do
            DownloadState.create_or_find_by!(model: @model.name)
          end
        now = Time.now
        downloaded =
          ActiveRecord::Base.connected_to(database: :global) do
            @model.where('hostname != ? AND uploaded_at > ? AND uploaded_at <= ?', hostname, download_state.downloaded_at, now).to_a
          end
        puts "Inserting #{downloaded.length} downloaded records of type #{@model.name}."
        download_state.downloaded_at = now
        ActiveRecord::Base.connected_to(database: :primary) do
          downloaded.each(&:save!)
          download_state.save!
        end
      end

      def sync!
        upload!
        download!
      end
    end
  end
end
