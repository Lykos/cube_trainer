# frozen_string_literal: true

require 'cube_trainer/wca/storer'
require 'cube_trainer/utils/array_helper'
require 'net/http'
require 'pathname'
require 'wombat'

module CubeTrainer
  module WCA
    # Helper class to crawl the WCA page and download the latest WCA export.
    class Crawler
      include Utils::ArrayHelper

      def initialize
        @storer = Storer.new
      end

      WCA_BASE_URL = 'https://www.worldcubeassociation.org'
      REDIRECT_LIMIT = 5

      def extract_link(links_on_export_page)
        find_only(links_on_export_page['links']) do |l|
          l =~ /WCA_export\d+_\w+Z\.tsv\.zip/
        end
      end

      def download_latest_file_name
        links_on_export_page = Wombat.crawl do
          base_url WCA_BASE_URL
          path '/results/misc/export.html'
          links({ xpath: '//a' }, :list)
        end
        extract_link(links_on_export_page)
      end

      def construct_wca_export_url(filename)
        URI.parse((WCA_BASE_URL + '/results/misc/' + filename).to_s)
      end

      def extract_redirect_url(resp)
        url = resp['location'] || resp.match(/<a href=\"([^>]+)\">/i)[1]
        raise 'No redirect URL found.' unless url
        raise "Redirect to foreign page #{url}." unless url[0...WCA_BASE_URL.length] == WCA_BASE_URL

        URI.parse(url)
      end

      def store_response(resp)
        File.open(@storer.wca_export_path(filename), 'wb') do |f|
          f.write(resp.body)
          puts 'Download successful.'
        end
      end

      def fetch(url)
        puts "Fetching #{url}"
        Net::HTTP.get_response(url)
      end

      def download_wca_export(filename)
        @storer.ensure_cache_directory_exists
        url = construct_wca_export_url(filename)
        store_response(fetch_with_redirects(url))
      end

      def fetch_with_redirects(url)
        REDIRECT_LIMIT.times do
          resp = fetch(url)
          return resp unless resp.is_a?(Net::HTTPRedirection)

          url = extract_redirect_url(resp)
        end
        raise 'Too many redirects.'
      end

      # Figures out what is the latest WCA export file, downloads it if we don't have it yet
      # and returns the filename.
      def download_latest_file
        filename = download_latest_file_name
        if @storer.wca_export_file_exists?(filename)
          puts "No download since we have #{filename} already."
        else
          download_wca_export(filename)
        end
        @storer.wca_export_path(filename)
      end
    end
  end
end
