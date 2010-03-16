# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

 ron = User.create!(:login => 'ron', :email => 'rnewman@thecia.net', :password=>'ron', :email_confirmed => true)
 #ron = User.create!(:login => 'ron', :email => 'rubyslippery@gmail.com', :password=>'ron', :email_confirmed => true)
 phoebe = User.create!(:login => 'phoebe',:email => 'phoebem@comcast.net', :password=>'phoebe',:encrypted_password => 'crypted_password', :email_confirmed => true)
#User.update_all('encrypted_password = crypted_password, email_confirmed = true')
 outdoors = Tag.create!(:name => 'outdoors', :uri => 'http://kalinda.us/ns/Outdoors', :description =>'Outdoors activities',:creator => phoebe )
 Tag.create(:name => 'hiking',:uri=>'http://kalinda.us/ns/Hiking', :parent => outdoors, :creator=> ron)
 Tag.create(:name => 'skiing', :uri=>'http://kalinda.us/ns/Sking', :parent => outdoors, :creator=> phoebe)
 culture = Tag.create!(:name => 'culture',  :uri=>'http://kalinda.us/ns/Culture', :description =>'Cultural activities' )
 museum = Tag.create(:name => 'museum',:uri=>'http://kalinda.us/ns/Museum', :parent => culture)
 Tag.create(:name => 'art museum', :uri=>'http://kalinda.us/ns/Art_Museum', :parent => museum, :creator => phoebe)
 Tag.create(:name => 'science museum',:uri=>'http://kalinda.us/ns/Science_Museum', :parent => museum, :creator => ron)

