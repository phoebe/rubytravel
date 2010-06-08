class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
	    t.string :login, :null => false
	    t.string :email
    	t.string :password
      t.datetime :last_login
	    t.string :first_name
	    t.string :last_name
	    t.date :birthday
	    
	    # user's current location
	    t.float :latitude  
	    t.float :longitude
	    
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
