class CreateStops < ActiveRecord::Migration
  def self.up
    create_table :stops do |t|
      t.float :lat
      t.float :lng
      t.string :name
      t.integer :number

      t.timestamps
    end
  end

  def self.down
    drop_table :stops
  end
end
