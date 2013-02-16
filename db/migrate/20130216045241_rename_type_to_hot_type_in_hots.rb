class RenameTypeToHotTypeInHots < ActiveRecord::Migration
  def up
    rename_column :hots, :type, :hot_type
  end

  def down
    rename_column :hots, :hot_type, :type
  end
end
