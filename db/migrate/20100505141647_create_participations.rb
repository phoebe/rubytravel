class CreateParticipations < ActiveRecord::Migration
  def self.up
    create_table :participations do |t|
      t.string :name               # Is this necessary?
      t.references :trip           # trip started by this or other user
      t.references :user           # user joins trip
      t.references :profile        # user is using this profile for this trip
      t.integer :radius           # distance in miles that user is willing to travel from his/her location
      t.date      :travel_date     # optional - when this person will join trip
      t.timestamps
    end
  end

  def self.down
    drop_table :participations
  end
end
