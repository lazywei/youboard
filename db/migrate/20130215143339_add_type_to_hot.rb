class AddTypeToHot < ActiveRecord::Migration
  def change
    add_column :hots, :type, :string
  end
end
