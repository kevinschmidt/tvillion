class Show
  attr_reader :name
  attr_accessor :season, :episode, :runtime, :hd, :date
  
  def initialize(name)
    @name = name
  end
  
  def to_s()
    return "Show[name=#{@name},season=#{@season},episode=#{@episode}]"
  end
  
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