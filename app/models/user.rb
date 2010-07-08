class User < ActiveRecord::Base
  include Clearance::User
  #attr_accessible :first_name,:last_name, :login
  has_many :tags, :foreign_key => :creator_id
  has_many :profiles, :dependent => :destroy
  has_many :participations #, :dependent => :destroy
  # participates in these trips
  has_many :part_trips, :through => :participations, :source => :trip
  # owns these trips
  has_many :own_trips, :class_name => "Trip", :foreign_key => :owner_id
  
  validates_uniqueness_of :email

  validates_format_of :email,
    :with => /^([^@\s]+)@((?:[-_+.%a-z0-9]+\.)+[a-z0-9]{2,})$/i
  
  # Do I participate in this trip?
  def part_trip?(trip)
    part_trips.include?(trip)
  end
  
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
