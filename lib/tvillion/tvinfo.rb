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
    
    def generate_show(result_show, current_date=DateTime.now())
      http_request = Net::HTTP.new(INFO_HOST, INFO_PORT)
      http_request.read_timeout = 500
      http_request.start do |http|
        count = 0
        begin
          if result_show.tvrage_id.nil?
            result_show.tvrage_id = get_show_id(http, result_show.name)
          end
          return get_show_info(http, result_show.tvrage_id, result_show, current_date)
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
        ids.push(id.text.to_i)
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
    
    def get_show_info(http, id, result_show, current_date=DateTime.now())
      resp = http.request_get(URI.parse(URI.escape(INFO_URL + id.to_s)).request_uri)
      xml_elements = REXML::Document.new(resp.body).root.elements
      result_show.name = xml_elements["name"].text
      result_show.image_url = xml_elements["image"].text
      
      airtime = xml_elements["airtime"].text
      timezone = xml_elements["timezone"].text
      result_show.runtime = xml_elements["runtime"].text.to_i
      result_show.hd = true
      
      result_show.next_show_date = nil
      result_show.next_season = nil
      result_show.next_episode = nil
      seasons_xml = xml_elements["Episodelist"].elements.to_a("//Season")
      seasons_xml.each do |season|
        season.elements.each do |episode|
          begin
            show_date = DateTime.parse(episode.elements['airdate'].text + " " + airtime + " " + timezone)
            if show_date > current_date
              result_show.next_show_date = show_date
              result_show.next_season = season.attributes['no'].to_i
              result_show.next_episode = episode.elements['seasonnum'].text.to_i
              break
            end
            result_show.last_show_date = show_date
            result_show.last_season = season.attributes['no'].to_i
            result_show.last_episode = episode.elements['seasonnum'].text.to_i  
          rescue ArgumentError => ex
            puts "Problem parsing episode info: " + ex.message
          end
        end
        unless result_show.next_show_date.nil?
          break
        end
      end
      
      return result_show
    end
  end
end
