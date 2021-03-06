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
    @transmission_client = TVillion::Transmission::Client.new('localhost', '9091')
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
      if show.episode > show.last_episode
        puts "cannot download episodes for #{show.name}, episode not yet aired"
        next
      end
      
      torrent_url = get_search_results(show.generate_search_string())
      unless torrent_url.nil?
        begin
          @id = @transmission_client.add_torrent(torrent_url)
          @download = Download.new(show_id: show.id, season: show.season, episode: show.episode, download_id: @id, status: TVillion::Transmission::StatusCode::UNKNOWN)
          @download.save
          puts @download.inspect
          get_next_episode(show)
          puts show.inspect
          show.update_attributes(params[:show])
        rescue Exception => e
          puts "error downloading show #{show.name}: " + e.message
        end
      else
        puts "cannot download episodes for #{show.name}, no torrents found"
      end
    end
    generate_response()
  end

  def update_download_status
    @transmission_client = TVillion::Transmission::Client.new('localhost', '9091')
    @downloads = Download.where(status != TVillion::Transmission::StatusCode::DONE)
    @downloads.each do |download|
      unless download.done? 
        @status_response = @transmission_client.check_torrent(download.download_id)
        download.status = @status_response.status
        download.progress = @status_response.percentDone
        download.update_attributes(params[:download])
      end
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
