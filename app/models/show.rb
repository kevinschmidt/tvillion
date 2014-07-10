class Show < ActiveRecord::Base
  include Comparable

  attr_accessor :current_download

  attr_accessible :name, :season, :episode, :tvrage_id, :runtime, :hd, :image_url, :last_show_date, :last_season, :last_episode, :next_show_date, :next_season, :next_episode, :search_name

  validates :name, :presence => true

  def generate_search_string()
    return "#{generate_name_string()} #{generate_hd_string()} #{generate_episode_string()}"
  end

  def generate_name_string()
    if search_name.nil? or search_name.blank?
      return name
    else
      return search_name
    end
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
  
  def future_download?()
    return false if season.nil? or episode.nil? or last_season.nil? or last_episode.nil?
    return (season==last_season and episode<=last_episode)
  end
  
  # compare based on next_show_date
  def <=>(other)
    return 0 if !next_show_date && !other.next_show_date
    return 1 if !next_show_date
    return -1 if !other.next_show_date
    next_show_date <=> other.next_show_date
  end
end
