class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.string :name, :null => false
      t.string :uri #, :null => false
      t.integer :creator_id
      t.integer :parent_id
      t.integer :children_count
      t.string :description
      t.timestamps
    end

    add_index :tags, :name,  :unique  => true
    #add_index :uri => "tag_index", :unique  => true

  end

  def self.down
    drop_table :tags
  end
end
