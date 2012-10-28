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
            raise "cannot generate show without tvrage_id"
          end
          return get_show_info(http, result_show.tvrage_id, result_show, current_date)
        rescue Errno::ECONNRESET
          count += count
          if count > 3
            raise
          end
          puts "got connection reset from tvrage.com trying to get tvinfo, request #{count}/3"
          retry
        end
      end
    end
    
    def get_next_episode(result_show)
      http_request = Net::HTTP.new(INFO_HOST, INFO_PORT)
      http_request.read_timeout = 500
      http_request.start do |http|
        count = 0
        begin
          if result_show.tvrage_id.nil?
            puts "skipping, no tvrage id for show " + result_show.name
            return
          end
          return find_next_episode(http, result_show.tvrage_id, result_show)
        rescue Errno::ECONNRESET
          count += count
          if count > 3
            raise
          end
          puts "got connection reset from tvrage.com trying to get tvinfo, request #{count}/3"
          retry
        end
      end
    end
    
    def search_show(title)
      http_request = Net::HTTP.new(INFO_HOST, INFO_PORT)
      http_request.read_timeout = 500
      http_request.start do |http|
        count = 0
        begin
          result = {}
          resp = http.request_get(URI.parse(URI.escape(SEARCH_URL + title)).request_uri)
          doc = REXML::Document.new(resp.body)
          doc.elements.each('Results/show') do |show|
            result[show.elements['showid'].text.to_i] = show.elements['name'].text
          end
          return result
        rescue Errno::ECONNRESET
          count += count
          if count > 3
            raise
          end
          puts "got connection reset from tvrage.com trying to get tvinfo, request #{count}/3"
          retry
        end
      end
    end
    
    def get_show_info(http, id, result_show, current_date=DateTime.now())
      resp = http.request_get(URI.parse(URI.escape(INFO_URL + id.to_s)).request_uri)
      xml_elements = REXML::Document.new(resp.body).root.elements
      result_show.name = xml_elements["name"].text
      result_show.image_url = xml_elements["image"].text
      
      return result_show unless xml_elements["airtime"] and xml_elements["timezone"] and xml_elements["runtime"]
      
      airtime = xml_elements["airtime"].text
      timezone = xml_elements["timezone"].text
      result_show.runtime = xml_elements["runtime"].text.to_i
      result_show.hd = false if result_show.hd.nil?
      
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
              if result_show.episode.nil?
                result_show.season = result_show.next_season
                result_show.episode = result_show.next_episode
              end
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
    
    def find_next_episode(http, id, result_show)
      resp = http.request_get(URI.parse(URI.escape(INFO_URL + id.to_s)).request_uri)
      xml_elements = REXML::Document.new(resp.body).root.elements
      
      found_new_episode = false
      seasons_xml = xml_elements["Episodelist"].elements.to_a("//Season")
      seasons_xml.each do |season|
        if result_show.season == season.attributes['no'].to_i
          season.elements.each_cons(2) do |episodes|
            begin
              if result_show.episode == episodes[0].elements['seasonnum'].text.to_i
                result_show.episode = episodes[1].elements['seasonnum'].text.to_i
                found_new_episode = true
                break
              end
            rescue ArgumentError => ex
              puts "Problem parsing episode info: " + ex.message
            end
          end
          break if found_new_episode
        end
        if result_show.season == season.attributes['no'].to_i - 1
          result_show.season = season.attributes['no'].to_i
          result_show.episode = 1
          found_new_episode = true
          break
        end
      end
      
      if not found_new_episode
        result_show.season = nil
        result_show.episode = nil
      end
      
      return result_show
    end
  end
end
