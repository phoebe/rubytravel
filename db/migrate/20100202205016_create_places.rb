class CreatePlaces < ActiveRecord::Migration
  def self.up
    create_table :places do |t|
      t.string :name, :null=> false
      t.float	:lat
      t.float	:lon
      t.integer	:parent_id
      t.string	:type
      t.text	:description
      t.timestamps
    end
  end

  def self.down
    drop_table :places
  end
end
