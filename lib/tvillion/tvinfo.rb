require 'date'
require 'net/http'
require 'rexml/document'
require "active_support/core_ext/numeric/time"

module TVillion
  module TvInfo
    INFO_HOST = "services.tvrage.com"
    INFO_PORT = "80"
    SEARCH_URL = "http://services.tvrage.com/feeds/search.php?show="
    INFO_URL = "http://services.tvrage.com/feeds/full_show_info.php?sid="
    
    def generate_show(result_show)
      http_request = Net::HTTP.new(INFO_HOST, INFO_PORT)
      http_request.read_timeout = 500
      http_request.start do |http|
        count = 0
        begin
          id = get_show_id(http, result_show.name)
          return get_show_info(http, id, result_show)
        rescue Errno::ECONNRESET
          count += count
          if count > 3
            raise
          end
          puts "got connection reset from tvrage.com trying to get tvinfo, request ${count}/3"
          retry
        end
      end
    end
    
    def get_show_id(http, title)
      resp = http.request_get(URI.parse(URI.escape(SEARCH_URL + title)).request_uri)
      doc = REXML::Document.new(resp.body)
      
      ids = []
      doc.elements.each('Results/show/showid') do |id|
        ids.push(id.text)
      end
      names = []
      doc.elements.each('Results/show/name') do |name|
        names.push(name.text)
      end
      
      id = nil
      names.each_with_index do |item, index|
        if item == title
          return ids[index]
        end
      end
      
      raise "show not found: " + title
    end
    
    def get_show_info(http, id, result_show)
      resp = http.request_get(URI.parse(URI.escape(INFO_URL + id)).request_uri)
      xml_elements = REXML::Document.new(resp.body).root.elements
      result_show.image_url = xml_elements["image"].text
      
      airtime = xml_elements["airtime"].text
      timezone = xml_elements["timezone"].text
      result_show.runtime = xml_elements["runtime"].text.to_i
      result_show.hd = true
      
      seasons_xml = xml_elements["Episodelist"].elements.to_a("//Season")
      result_show.season = seasons_xml.last.attributes['no'].to_i
      seasons_xml.last.elements.each do |episode|
        next_show_date = DateTime.parse(episode.elements['airdate'].text + " " + airtime + " " + timezone) + (result_show.runtime.to_f / 24 / 60)
        if next_show_date > DateTime.now()
          result_show.next_show_date = next_show_date
          result_show.episode = episode.elements['seasonnum'].text.to_i - 1
          break
        end
      end
      
      return result_show
    end
  end
end
