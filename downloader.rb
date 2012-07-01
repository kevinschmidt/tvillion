require_relative 'show'
require 'date'

class Downloader
  attr_reader :shows
  
  def initialize()
    @shows = []
  end
  
  def prepare_data()
    s = Show.new("True Blood")
    s.season = 5
    s.episode = 4
    s.runtime = 60
    s.date = DateTime.parse("2012-07-01 21:00:00 EST")
    @shows.push(s)
  end
end

if __FILE__ == $0
  d = Downloader.new()
  d.prepare_data()
  p d.shows
end