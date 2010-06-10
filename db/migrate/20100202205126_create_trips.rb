class CreateTrips < ActiveRecord::Migration
  def self.up
    create_table :trips do |t|
      t.references :user
      t.string :name
      t.string :description
      t.date  :departureDate
      t.integer   :duration
      t.float   :latitude
      t.float   :longitude
      t.timestamps
    end
  end

  def self.down
    drop_table :trips
  end
end
