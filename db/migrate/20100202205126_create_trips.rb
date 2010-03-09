class CreateTrips < ActiveRecord::Migration
  def self.up
    create_table :trips do |t|
      t.references :user
      t.references :profile
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :trips
  end
end
