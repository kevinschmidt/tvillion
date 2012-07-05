require_relative 'show'
require 'date'
require 'json'
require 'net/http'
require 'eventmachine'
require_relative 'transmission'

class Downloader
  SEARCH_ENGINE_URLS = ["http://ca.isohunt.com/js/json.php?ihq="]
  
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
  
  def get_search_results()
    SEARCH_ENGINE_URLS.each() do |url|
      shows.each() do |show|
        resp = Net::HTTP.get_response(URI.parse(URI.escape(url + show.generate_search_string())))
        data = resp.body
        result = JSON.parse(data)
        if result.has_key? 'items'
          items = result['items']['list']
          puts JSON.pretty_generate(items[0])
          return items[0]['enclosure_url']
        end
        return nil
      end
    end
  end
end

if __FILE__ == $0
  d = Downloader.new()
  d.prepare_data()
  p d.shows
  t = d.get_search_results()
  puts t
  
  trans = Transmission::Client.new('media.lan', '9091')
  trans.add_torrent(t)
end
