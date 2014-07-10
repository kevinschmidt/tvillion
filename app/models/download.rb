require 'tvillion/transmission'

class Download < ActiveRecord::Base
  include Comparable

  attr_accessible :show_id, :season, :episode, :download_id, :status, :progress

  validates :show_id, :season, :episode, :download_id, :status, :presence => true


  # compare based on status
  def <=>(other)
    status <=> other.status
  end

  def done?
    status == TVillion::Transmission::StatusCode::DONE
  end

  def progressPercent
    if progress.nil?
      0
    else
      progress * 100
    end
  end

  def statusName
    TVillion::Transmission::StatusCode::get_name_from_transmission_status(status)
  end
end
