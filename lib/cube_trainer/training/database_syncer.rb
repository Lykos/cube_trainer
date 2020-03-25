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
        puts 'Fetching uploads.'
        to_upload = fetch_to_upload
        if to_upload.empty?
          puts 'Nothing to upload.'
          return
        end

        upload(to_upload)
        save_uploaded_at(to_upload)
      end

      def download!
        puts 'Fetching downloads.'
        download_state = fetch_download_state
        now = Time.now
        downloaded = fetch_downloaded(download_state, now)
        save_downloaded(downloaded)
        download_state.downloaded_at = now
        ActiveRecord::Base.connected_to(database: :primary) do
          download_state.save!
        end
      end

      def sync!
        upload!
        download!
      end

      private

      def save_downloaded(downloaded)
        puts "Inserting #{downloaded.length} downloaded records of type #{@model.name}."
        progress_bar = ProgressBar.create(title: 'Inserted', total: downloaded.length)
        ActiveRecord::Base.connected_to(database: :primary) do
          downloaded.each do |u|
            create_or_update_by_key(u)
            progress_bar.increment
          end
        end
      end

      def fetch_to_upload
        ActiveRecord::Base.connected_to(database: :primary) do
          @model.where(
            'hostname = ? AND (uploaded_at IS NULL OR updated_at > uploaded_at)',
            hostname
          ).to_a
        end
      end

      def save_uploaded_at(uploaded)
        puts 'Saving updated uploaded_at timestamps.'
        progress_bar = ProgressBar.create(title: 'Saved', total: uploaded.length)
        ActiveRecord::Base.connected_to(database: :primary) do
          uploaded.each do |u|
            u.save(touch: false)
            progress_bar.increment
          end
        end
      end

      def create_or_update_by_key(equivalent_item)
        new_item = @model.create_or_find_by!(
          hostname: equivalent_item.hostname,
          created_at: equivalent_item.created_at
        )
        copy_non_key_attributes(from: equivalent_item, to: new_item)
        new_item.save!
      end

      def copy_non_key_attributes(from:, to:)
        from.attributes.each do |k, v|
          next if %w[hostname created_at id].include?(k)

          to.send('${k}=', v)
        end
      end

      def upload(to_upload)
        puts "Uploading #{to_upload.length} records of type #{@model.name}."
        progress_bar = ProgressBar.create(title: 'Uploaded', total: to_upload.length)
        ActiveRecord::Base.connected_to(database: :global) do
          to_upload.each do |u|
            u.uploaded_at = Time.now
            create_or_update_by_key(u)
            progress_bar.increment
          end
        end
      end

      def fetch_downloaded(download_state, now)
        if download_state.downloaded_at
          ActiveRecord::Base.connected_to(database: :global) do
            @model.where(
              'hostname != ? AND uploaded_at > ? AND uploaded_at <= ?',
              hostname, download_state.downloaded_at, now
            ).to_a
          end
        else
          ActiveRecord::Base.connected_to(database: :global) do
            @model.where(
              'hostname != ? AND uploaded_at <= ?',
              hostname, now
            ).to_a
          end
        end
      end

      def fetch_download_state
        ActiveRecord::Base.connected_to(database: :primary) do
          DownloadState.create_or_find_by!(model: @model.name)
        end
      end
    end
  end
end
