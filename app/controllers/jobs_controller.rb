require 'tvillion/tvinfo'

class JobsController < ApplicationController
  include TVillion::TvInfo
  
  def get_tvinfo
    @shows = Show.all
    @shows.each do |show|
      generate_show(show)
      puts show
      puts show.name
      puts show.episode
      puts show.season
      puts show.next_show_date
      puts show.image_url
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
