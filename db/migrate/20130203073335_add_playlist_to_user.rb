class AddPlaylistToUser < ActiveRecord::Migration
  def change
    add_column :users, :playlist, :string
  end
end
