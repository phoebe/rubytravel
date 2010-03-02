class CreateProfilesTags < ActiveRecord::Migration
  def self.up
    create_table :profiles_tags do |t|
      t.references :profile
      t.references :tag
      
      t.timestamps
    end
  end

  def self.down
    drop_table :profiles_tags
  end
end
