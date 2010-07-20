class AddUser < ActiveRecord::Migration
  def self.up
    User.create!( :email => 'phoebepost@gmail.com',:password=>'phoebe', :email_confirmed=>'true')
  end

  def self.down
  end
end
