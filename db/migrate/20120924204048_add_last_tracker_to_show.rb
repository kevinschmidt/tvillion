class AddLastTrackerToShow < ActiveRecord::Migration
  def change
    add_column :shows, :last_show_date, :datetime
    add_column :shows, :last_season, :integer
    add_column :shows, :last_episode, :integer
  end
end
