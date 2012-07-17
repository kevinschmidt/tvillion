require 'date'
require 'json'
require 'net/http'

require 'tvillion/show'
require 'tvillion/transmission'
require 'tvillion/torrentsearch'
require 'tvillion/tvinfo'

module TVillion
  class Downloader
    include TorrentSearch
    include TvInfo
    
    attr_reader :shows
    
    def initialize(transmission_host, transmission_port)
      @show_names = []
      @transmission_client = Transmission::Client.new(transmission_host, transmission_port)
    end
    
    def start_download()
      @show_names.each do |show_name|
        show = generate_show(show_name)
        if show
          torrent_url = get_search_results(show.generate_search_string())
          if torrent_url
            @transmission_client.add_torrent(torrent_url)
          end
        end
      end
    end
    
    def add_show(show_name)
      @show_names.push(show_name)
    end
  end
end
