class CreatePlaylists < ActiveRecord::Migration
  def change
    create_table :playlists do |t|
      t.integer :user_id
      t.string :p_id
      t.string :hot_type
      t.datetime :last_updated_at

      t.timestamps
    end
  end
end
