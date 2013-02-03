class CreateHots < ActiveRecord::Migration
  def change
    create_table :hots do |t|
      t.integer :id
      t.text :songs

      t.timestamps
    end
  end
end
