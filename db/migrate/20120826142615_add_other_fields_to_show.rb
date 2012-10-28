class AddOtherFieldsToShow < ActiveRecord::Migration
  def change
    add_column :shows, :season, :integer
    add_column :shows, :episode, :integer
    add_column :shows, :runtime, :integer
    add_column :shows, :hd, :boolean
    add_column :shows, :image_url, :string
    add_column :shows, :next_show_date, :datetime
  end
end
