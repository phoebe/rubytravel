class CreateTrips < ActiveRecord::Migration
  def self.up
    create_table :trips do |t|
      t.references :owner
      t.string :name
      t.string :description
      t.date  :departure_date
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
