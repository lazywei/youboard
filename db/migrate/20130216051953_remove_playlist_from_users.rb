class RemovePlaylistFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :playlist
    remove_column :users, :updated_playlist_at
  end

  def down
    add_column :users, :playlist
    add_column :users, :updated_playlist_at
  end
end
