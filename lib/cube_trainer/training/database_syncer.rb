# frozen_string_literal: true

require 'cube_trainer/training/download_state'
require 'ruby-progressbar'

module CubeTrainer
  module Training
    # Class that syncs a model with the global database.
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
        puts "Fetching uploads."
        uploaded = fetch_uploaded
        now = Time.now
        puts "Uploading #{uploaded.length} records of type #{@model.name}."
        uploaded.each { |item| item.uploaded_at = now }
        upload(uploaded)
        puts "Saving updated uploaded_at timestamps."
        progress_bar = ProgressBar.create(title: 'Saved', total: uploaded.length)
        ActiveRecord::Base.connected_to(database: :primary) do
          uploaded.each do |u|
            u.save(touch: false)
            progress_bar.increment
          end
        end
        puts "Saved updated uploaded_at timestamps."
      end

      def download!
        puts "Fetching downloads."
        download_state = fetch_download_state
        now = Time.now
        downloaded = fetch_downloaded(download_state, now)
        puts "Inserting #{downloaded.length} downloaded records of type #{@model.name}."
        downloaded.each { |d| d.id = nil }
        download_state.downloaded_at = now
        ActiveRecord::Base.connected_to(database: :primary) do
          @model.import(downloaded)
          download_state.save!
        end
      end

      def sync!
        upload!
        download!
      end

      private

      def fetch_uploaded
        ActiveRecord::Base.connected_to(database: :primary) do
          @model.where(
            'hostname = ? AND (uploaded_at IS NULL OR updated_at > uploaded_at)',
            hostname
          ).to_a
        end
      end

      def upload(uploaded)
        stuff = uploaded.map do |u|
          u = u.dup
          u.id = nil
          u
        end
        ActiveRecord::Base.connected_to(database: :global) do
          @model.import(stuff)
        end
      end

      def fetch_downloaded(download_state, now)
        ActiveRecord::Base.connected_to(database: :global) do
          if download_state.downloaded_at
            @model.where(
              'hostname != ? AND uploaded_at > ? AND uploaded_at <= ?',
              hostname, download_state.downloaded_at, now
            )
          else
            @model.where(
              'hostname != ? AND uploaded_at <= ?',
              hostname, now
            )
          end
        end.to_a
      end

      def fetch_download_state
        ActiveRecord::Base.connected_to(database: :primary) do
          DownloadState.create_or_find_by!(model: @model.name)
        end
      end
    end
  end
end
