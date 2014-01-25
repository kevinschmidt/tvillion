class Download < ActiveRecord::Base
  include Comparable

  attr_accessible :show_id, :season, :episode, :download_id, :status, :progress

  validates :show_id, :season, :episode, :download_id, :status, :presence => true


  # compare based on status
  def <=>(other)
    status <=> other.status
  end
end
