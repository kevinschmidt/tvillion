class CreateDownloads < ActiveRecord::Migration
  def change
    create_table :downloads do |t|
      t.integer :show_id
      t.integer :season
      t.integer :episode
      t.string :download_id
      t.integer :status
      t.float :progress

      t.timestamps
    end

    add_index :downloads, [:show_id], :name => 'downloads_show_id'
    add_index :downloads, [:download_id], :name => 'downloads_download_id'
  end
end
