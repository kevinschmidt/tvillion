class Show < ActiveRecord::Base
  attr_accessible :name, :season, :episode, :runtime, :hd, :image_url, :last_show_date, :last_season, :last_episode, :next_show_date, :next_season, :next_episode
  
  validates :name, :presence => true
  
  def generate_search_string()
    return "#{@name} #{generate_hd_string()} #{generate_episode_string()}"
  end

  def generate_hd_string()
    if hd
      return "720p"
    else
      return ""
    end
  end

  def generate_episode_string()
    return "S%02dE%02d" % [season, episode]
  end
end
