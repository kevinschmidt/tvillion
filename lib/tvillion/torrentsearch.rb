require 'json'
require 'net/http'
require 'cgi'
require "rexml/document"

module TVillion
  module TorrentSearch
    def get_search_results(search_string)
      search_zooqle(search_string)
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

    ZOOQLE_URL = "https://zooqle.com/search?q=%s&fmt=rss"

    def search_zooqle(search_string)
      uri = URI.parse(URI.escape(ZOOQLE_URL % search_string))
      net_http = Net::HTTP.new(uri.host, uri.port)
      net_http.use_ssl = true
      resp = net_http.get(uri.request_uri)
      data = resp.body

      begin
        raise "got a bad response from zooqle: " + resp.message if resp.code != "200"
        result = REXML::Document.new(data)
        return REXML::XPath.first(result, "//channel/item[1]/torrent:magnetURI").text
      rescue => ex
        puts "Error: #{ex}"
        return nil
      end
    end
  end
end
