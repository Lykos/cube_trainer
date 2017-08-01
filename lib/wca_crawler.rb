require 'net/http'
require 'pathname'
require 'wca_storer'
require 'wombat'

class WCACrawler

  def initialize
    @storer = WCAStorer.new
  end

  WCA_HOST = 'www.worldcubeassociation.org'
  WCA_BASE_URL = 'https://' + WCA_HOST
  
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
    (Pathname.new('/results/misc/') + filename).to_s
  end

  def download_wca_export(filename)
    @storer.ensure_base_directory_exists
    Net::HTTP.start(WCA_HOST) do |http|
      resp = http.get(construct_wca_export_url(filename))
      File.open(@storer.wca_export_path(filename), 'wb') do |f|
        f.write(resp.body)
      end
    end
  end

  # Figures out what is the latest WCA export file, downloads it if we don't have it yet
  # and returns the filename.
  def get_latest_file
    filename = get_latest_file_internal
    if !@storer.has_wca_export_file(filename)
      download_wca_export(filename)
    end
    @storer.wca_export_path(filename)
  end
  
end
