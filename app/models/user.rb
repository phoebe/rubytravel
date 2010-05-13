class User < ActiveRecord::Base
  include Clearance::User
  #attr_accessible :first_name,:last_name, :login
  has_many :tags, :foreign_key => :creator_id
  has_many :profiles, :dependent => :destroy
  #has_many :trips                             # trips initialed by this user
  # too confusing - only thru participation with roles
  has_many :participations #, :dependent => :destroy
  has_many :trips, :through => :participations  # participate in these trips
  
  validates_uniqueness_of :email

  validates_format_of :email,
    :with => /^([^@\s]+)@((?:[-_+.%a-z0-9]+\.)+[a-z0-9]{2,})$/i
  
  def handle()   
    if  (! self.first_name.nil? ) 
      return (self.first_name);
    elsif  (! self.last_name.nil? ) 
      return (self.last_name);
    elsif  (! self.login.nil?)
      return self.login
    elsif  (! self.email.nil?)
      return self.email;
    else
      return "Mystery!"
    end
  end
  
  #def self.authenticate_unsafely(user_name, password)
    #find(:first, :conditions => "user_name = '#{user_name}' AND password = '#{password}'")
  #end

  #def self.authenticate_safely(user_name, password)
    #find(:first, :conditions => [ "user_name = ? AND password = ?", user_name, password ])
  #end

  #def self.authenticate_safely_simply(user_name, password)
    #find(:first, :conditions => { :user_name => user_name, :password => password })
  #end


end
