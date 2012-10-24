class AddSearchNameToShow < ActiveRecord::Migration
  def change
    add_column :shows, :search_name, :string
  end
end
