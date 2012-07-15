require 'json'
require 'net/http'

module TVillion
  module TorrentSearch
    SEARCH_ENGINE_URLS = ["http://ca.isohunt.com/js/json.php?ihq="]
    
    def get_search_results(search_string)
      SEARCH_ENGINE_URLS.each() do |url|
        resp = Net::HTTP.get_response(URI.parse(URI.escape(url + search_string)))
        data = resp.body
        result = JSON.parse(data)
        if result.has_key? 'items'
          items = result['items']['list']
          return items[0]['enclosure_url']
        end
        return nil
      end
    end
  end
end