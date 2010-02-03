# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

 ron = User.create!(:login => 'ron' )
 phoebe = User.create!(:login => 'phoebe' )
 outdoors = Tag.create!(:name => 'outdoors', :description =>'Outdoors activities',:creator => phoebe )
 Tag.create(:name => 'hiking', :parent => outdoors, :creator=> ron)
 Tag.create(:name => 'skiing', :parent => outdoors, :creator=> phoebe)
 culture = Tag.create!(:name => 'culture', :description =>'Cultural activities' )
 museum = Tag.create(:name => 'museum', :parent => culture)
 Tag.create(:name => 'art museum', :parent => museum, :creator => phoebe)
 Tag.create(:name => 'science museum', :parent => museum, :creator => ron)

