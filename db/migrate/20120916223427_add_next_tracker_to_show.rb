class AddNextTrackerToShow < ActiveRecord::Migration
  def change
    add_column :shows, :next_season, :integer
    add_column :shows, :next_episode, :integer
  end
end
