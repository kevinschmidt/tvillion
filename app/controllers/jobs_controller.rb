require 'tvillion/transmission'
require 'tvillion/torrentsearch'
require 'tvillion/tvinfo'

class JobsController < ApplicationController
  include TVillion::TvInfo
  include TVillion::TorrentSearch
  
  def get_tvinfo
    @shows = Show.all
    @shows.each do |show|
      generate_show(show)
      puts show.inspect
      show.update_attributes(params[:show])
    end
    generate_response()
  end
  
  def schedule_next_download
    @transmission_client = TVillion::Transmission::Client.new('media.lan', '9091')
    @shows = Show.all
    @shows.each do |show|
      if show.season.nil? or show.episode.nil?
        puts "skipping #{show.name}, no episodes to download"
        next
      end
      if show.season != show.last_season
        puts "cannot download episodes for #{show.name}, download from a different season not supported"
        next
      end
      
      torrent_url = get_search_results(show.generate_search_string())
      unless torrent_url.nil?
        @transmission_client.add_torrent(torrent_url)
        if show.last_episode == show.episode
          show.season = nil
          show.episode = nil
        else
          show.episode = show.episode+1
        end
      end
      show.update_attributes(params[:show])
    end
    generate_response()
  end
  
  private
  def generate_response
    @status = Status.new()
    @status.result = "success"
    respond_to do |format|
      format.html
      format.xml  { render :xml => @status }
      format.json { render :json => @status }
    end
  end
  
  class Status
    attr_accessor :result
  end
end
