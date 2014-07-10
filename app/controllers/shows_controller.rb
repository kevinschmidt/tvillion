require 'tvillion/tvinfo'

class ShowsController < ApplicationController
  include TVillion::TvInfo

  # GET /shows
  # GET /shows.json
  def index
    @shows = Show.all
    @shows.each do |show|
      download = Download.where(show_id: show.id).order("season desc, episode desc").first
      unless download.nil?
        show.current_download = download
      end
    end
    @shows.sort!

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @shows }
    end
  end

  # GET /shows/1
  # GET /shows/1.json
  def show
    @show = Show.find(params[:id])
    @downloads = Download.where(show_id: params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @show }
    end
  end

  # GET /shows/new
  # GET /shows/new.json
  def new
    @show = Show.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @show }
    end
  end

  # GET /shows/1/edit
  def edit
    @show = Show.find(params[:id])
  end

  # POST /shows
  # POST /shows.json
  def create
    @show = Show.new(params[:show])

    respond_to do |format|
      if @show.save
        format.html { redirect_to @show, notice: 'Show was successfully created.' }
        format.json { render json: @show, status: :created, location: @show }
      else
        format.html { render action: "new" }
        format.json { render json: @show.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /shows/1
  # PUT /shows/1.json
  def update
    @show = Show.find(params[:id])

    respond_to do |format|
      if @show.update_attributes(params[:show])
        format.html { redirect_to @show, notice: 'Show was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @show.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shows/1
  # DELETE /shows/1.json
  def destroy
    @show = Show.find(params[:id])
    @show.destroy

    respond_to do |format|
      format.html { redirect_to shows_url }
      format.json { head :no_content }
    end
  end

  # GET /shows/search.json
  def search
    if params.include?(:query)
      @search_result = search_show(params[:query])
      puts @search_result
    end
    
    respond_to do |format|
      format.js
      format.html
      format.json { render json: @search_result }
    end
  end

  # GET /shows/1/downloads.json
  def downloads
    @downloads = Download.where(show_id: params[:id])
    
    respond_to do |format|
      format.json { render json: @downloads }
    end
  end
end
