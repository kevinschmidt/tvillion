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
    
    def initialize()
      @shows = []
    end
  end
end
