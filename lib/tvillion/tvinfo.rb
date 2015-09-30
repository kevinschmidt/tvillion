require 'date'
require 'net/http'
require 'json'
require "active_support/core_ext/numeric/time"

module TVillion
  module TvInfo
    SEARCH_URL = "http://api.tvmaze.com/search/shows?q=%s"
    INFO_URL = "http://api.tvmaze.com/shows/%s"
    EPISODE_URL = "http://api.tvmaze.com/shows/%s/episodes"
    
    def search_show(title)
      results = {}
      uri = URI.parse(URI.escape(SEARCH_URL % title))
      resp = Net::HTTP.new(uri.host, uri.port).get(uri.request_uri)
      response = JSON.parse(resp.body)
      response.each do |show|
        results[show['show']['id'].to_i] = show['show']['name']
      end
      return results
    end
    
    def generate_show(result_show)
      if result_show.tvrage_id.nil?
        raise "cannot generate show without tvrage_id"
      end
      
      uri = URI.parse(URI.escape(INFO_URL % result_show.tvrage_id.to_s))
      resp = Net::HTTP.new(uri.host, uri.port).get(uri.request_uri)
      if resp.code != "200"
        puts "error retrieving show [" + result_show.name + "]: " + resp.body
        return result_show
      end
      response = JSON.parse(resp.body)
      
      result_show.name = response["name"]
      result_show.image_url = response["image"]["medium"]
      result_show.runtime = response["runtime"].to_i
      result_show.hd = true
      
      result_show.next_show_date = nil
      result_show.next_season = nil
      result_show.next_episode = nil
      
      if response["_links"]["previousepisode"]
        episode = get_episode_info(response["_links"]["previousepisode"]["href"])
        result_show.last_show_date = episode["date"]
        result_show.last_season = episode["season"]
        result_show.last_episode = episode["episode"]
      end
      
      if response["_links"]["nextepisode"]
        episode = get_episode_info(response["_links"]["nextepisode"]["href"])
        result_show.next_show_date = episode["date"]
        result_show.next_season = episode["season"]
        result_show.next_episode = episode["episode"]
      end
    end
    
    def get_next_episode(result_show)
      if result_show.tvrage_id.nil?
        raise "cannot generate show without tvrage_id"
      end
      
      uri = URI.parse(URI.escape(EPISODE_URL % result_show.tvrage_id.to_s))
      resp = Net::HTTP.new(uri.host, uri.port).get(uri.request_uri)
      if resp.code != "200"
        puts "error retrieving show [" + result_show.name + "]: " + resp.body
        return result_show
      end
      response = JSON.parse(resp.body)
      
      found_new_episode = false
      response.each_cons(2) do |episodes|
        if result_show.season == episodes[0]["season"].to_i && result_show.episode == episodes[0]["number"].to_i
          result_show.season = episodes[1]["season"].to_i 
          result_show.episode = episodes[1]["number"].to_i
          found_new_episode = true
          break
        end
      end
      if not found_new_episode
        result_show.season = nil
        result_show.episode = nil
      end
    end
    
    private
      def get_episode_info(url)
        uri = URI.parse(URI.escape(url))
        resp = Net::HTTP.new(uri.host, uri.port).get(uri.request_uri)
        if resp.code != "200"
          puts "error retrieving episode info from url [" + url + "]: " + resp.body
          return result_show
        end
        response = JSON.parse(resp.body)
        
        result = {}
        result["date"] = DateTime.parse(response["airstamp"])
        result["season"] = response["season"].to_i
        result["episode"] = response["number"].to_i
        return result
      end
  end
end
