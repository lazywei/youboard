class AddUpdatedPlaylistAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :updated_playlist_at, :datetime
  end
end
