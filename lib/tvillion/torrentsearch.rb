require 'json'
require 'net/http'
require 'cgi'
require "rexml/document"

module TVillion
  module TorrentSearch
    def get_search_results(search_string)
      search_kickass(search_string)
    end

    THORRENTS_URL = "http://thorrents.com/search/%s.json"
    
    def search_thorrents(search_string)
      resp = Net::HTTP.get_response(URI.parse(URI.escape(THORRENTS_URL % search_string)))
      data = resp.body
      result = JSON.parse(data)
      if result.has_key? 'results' and not result['results'].empty?
        items = result['results']
        return items[0]['magnet']
      end
      return nil
    end

    FENOPY_URL = "http://fenopy.se/module/search/api.php?keyword=%s&sort=relevancy&format=json&limit=10&category=78"

    def search_fenopy(search_string)
      resp = Net::HTTP.get_response(URI.parse(URI.escape(FENOPY_URL % search_string)))
      data = resp.body
      result = JSON.parse(data)
      if not result.empty?
        return CGI.unescapeHTML(result[0]['magnet'])
      end
      return nil
    end

    KICKASS_URL = "http://kat.cr/usearch/%s/?rss=1&field=seeders&sorder=desc"

    def search_kickass(search_string)
      uri = URI.parse(URI.escape(KICKASS_URL % search_string))
      resp = Net::HTTP.new(uri.host, uri.port).get(uri.request_uri)
      data = resp.body

      begin
        raise "got a bad response from kickass: " + resp if resp.code != "200"
        result = REXML::Document.new(data)
        return REXML::XPath.first(result, "//channel/item[1]/torrent:magnetURI").text
      rescue => ex
        puts "Error: #{ex}"
        return nil
      end
    end
  end
end
