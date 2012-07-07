require 'date'
require 'json'
require 'net/http'
require 'eventmachine'

require 'tvillion/show'
require 'tvillion/transmission'
require 'tvillion/torrentsearch'
require 'tvillion/tvinfo'

class Downloader
  include TorrentSearch
  include TvInfo
  
  attr_reader :shows
  
  def initialize()
    @shows = []
  end
end

if __FILE__ == $0
  d = Downloader.new()
  show = d.generate_show(ARGV[0])
  puts show
  t = d.get_search_results(show.generate_search_string())
  puts t
  
  trans = Transmission::Client.new('media.lan', '9091')
  trans.add_torrent(t)
end
