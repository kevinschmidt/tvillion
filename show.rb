class Show
  attr_reader :name
  attr_accessor :season, :episode, :runtime, :date
  
  def initialize(name)
    @name = name
  end
  
  def to_s()
    return "Show[name=#{@name},season=#{@season},episode=#{@episode}]"
  end
end