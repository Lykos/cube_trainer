require 'net/http'
require 'pathname'
require 'cube_trainer/wca_storer'
require 'wombat'

module CubeTrainer

  class WCACrawler
  
    def initialize
      @storer = WCAStorer.new
    end
  
    WCA_BASE_URL = 'https://www.worldcubeassociation.org'
    REDIRECT_LIMIT = 5
    
    def get_latest_file_internal
      links_on_export_page = Wombat.crawl do
        base_url WCA_BASE_URL
        path '/results/misc/export.html'
        links({xpath: '//a'}, :list)
      end
      matching_links = links_on_export_page['links'].select do |l|
        l =~ /WCA_export\d+_\d+\.tsv\.zip/
      end
      raise 'No WCA export found.' if matching_links.empty?
      raise 'Multiple WCA exports found.' if matching_links.length > 1
      matching_links.first
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
  
    def download_wca_export(filename)
      @storer.ensure_base_directory_exists
      REDIRECT_LIMIT.times do
        url = construct_wca_export_url(filename)
        puts "Downloading #{url}"
        resp = Net::HTTP.get_response(url)
        if resp.kind_of?(Net::HTTPRedirection)
          url = extract_redirect_url(resp)
        else
          File.open(@storer.wca_export_path(filename), 'wb') do |f|
            f.write(resp.body)
            puts 'Download successful.'
            return
          end
        end
        raise 'Too many redirects.'
      end
    end
  
    # Figures out what is the latest WCA export file, downloads it if we don't have it yet
    # and returns the filename.
    def get_latest_file
      filename = get_latest_file_internal
      if @storer.has_wca_export_file(filename)
        puts "No download since we have #{filename} already."
      else
        download_wca_export(filename)
      end
      @storer.wca_export_path(filename)
    end
    
  end

end
