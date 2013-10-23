require 'json'
require 'net/http'

module TVillion
  module TorrentSearch
    THORRENTS_URL = "http://thorrents.com/search/%s.json"
    
    def get_search_results(search_string)
      resp = Net::HTTP.get_response(URI.parse(URI.escape(THORRENTS_URL % search_string)))
      data = resp.body
      result = JSON.parse(data)
      if result.has_key? 'results' and not result['results'].empty?
        items = result['results']
        return items[0]['magnet']
      end
      return nil
    end
  end
end