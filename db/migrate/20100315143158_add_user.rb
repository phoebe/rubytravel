class AddUser < ActiveRecord::Migration
  def self.up
    User.create!(:login => 'admin', :email => 'phoebepost@gmail.com',:password=>'phoebe', :email_confirmed=>'true')
  end

  def self.down
  end
end
