require 'date'
require 'json'
require 'net/http'
require 'eventmachine'

require 'tvillion/show'
require 'tvillion/transmission'
require 'tvillion/torrentsearch'

class Downloader
  include TorrentSearch
  
  attr_reader :shows
  
  def initialize()
    @shows = []
  end
  
  def prepare_data()
    s = Show.new("True Blood")
    s.season = 5
    s.episode = 3
    s.runtime = 60
    s.hd = true
    s.date = DateTime.parse("2012-07-01 21:00:00 EST")
    @shows.push(s)
  end
end

if __FILE__ == $0
  d = Downloader.new()
  d.prepare_data()
  p d.shows
  t = d.get_search_results(d.shows[0].generate_search_string())
  puts t
  
  trans = Transmission::Client.new('media.lan', '9091')
  trans.add_torrent(t)
end
