# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

ron = User.find_or_create_by_login(:login => 'ron', :email => 'rnewman@thecia.net', :password=>'ron', :email_confirmed => true)
phoebe = User.find_or_create_by_login(:login => 'phoebe',:email => 'phoebem@comcast.net', :password=>'phoebe',:encrypted_password => 'crypted_password', :email_confirmed => true)
Profile.find_or_create_by_name_and_user_id(:name => 'work travel',:user=>phoebe, :description => 'Preferences for work related travelling'); 

#User.update_all('encrypted_password = crypted_password, email_confirmed = true')
 outdoors = Tag.find_or_create_by_name(:name => 'outdoors', :uri => 'http://kalinda.us/ns/Outdoors',
                        :description =>'Outdoors activities',:code=>"OUT", :creator => phoebe )
 Tag.find_or_create_by_name(:name => 'hiking',:uri=>'http://kalinda.us/ns/Hiking',
                       :parent => outdoors, :code=>'TRL',:creator=> ron)
 Tag.find_or_create_by_name(:name => 'skiing', :uri=>'http://kalinda.us/ns/Sking',:code=> "SKI",
                       :parent => outdoors, :creator=> phoebe)
 Tag.find_or_create_by_name(:name => 'biking', :uri=>'http://kalinda.us/ns/Biking',:code=> "BIKE",
                       :parent => outdoors, :creator=> phoebe)
 Tag.find_or_create_by_name(:name => 'golf', :uri=>'http://kalinda.us/ns/Golf', :code=> "GOLF",
                       :parent => outdoors, :creator=> phoebe)
 Tag.find_or_create_by_name(:name => 'fishing', :uri=>'http://kalinda.us/ns/Fishing',
                       :code =>'RGNL', :parent => outdoors, :creator=> phoebe)


 culture = Tag.find_or_create_by_name(:name => 'culture',  :uri=>'http://kalinda.us/ns/Culture',
                       :code =>'CULT',:description =>'Cultural activities' )
 museum = Tag.find_or_create_by_name(:name => 'museum',:uri=>'http://kalinda.us/ns/Museum',
                       :code => 'MUS', :parent => culture)
 Tag.find_or_create_by_name(:name => 'art museum', :uri=>'http://kalinda.us/ns/Art_Museum',
                       :code => 'MUS',  :parent => museum, :creator => phoebe)
 Tag.find_or_create_by_name(:name => 'science museum',:uri=>'http://kalinda.us/ns/Science_Museum',
                      :code=> 'MUS', :parent => museum, :creator => ron)
 Tag.find_or_create_by_name(:name => 'history', :uri=>'http://kalinda.us/ns/History',
                      :code=> 'HSTS', :parent => culture, :creator => phoebe)

 cuisine = Tag.find_or_create_by_name(:name => 'food and drink',  :uri=>'http://kalinda.us/ns/Food_and_Drink',
                     :code=>"FOOD", :description =>'Food and Drinks' )
 Tag.find_or_create_by_name(:name => 'wine tasting',:uri=>'http://kalinda.us/ns/Wine_Tasting',
                     :code=> 'WINE', :parent => cuisine, :creator => phoebe)
 Tag.find_or_create_by_name(:name => 'Breweries',:uri=>'http://kalinda.us/ns/micro_breweries',
                     :code=>'MFGB', :parent => cuisine, :creator => phoebe)
 Tag.find_or_create_by_name(:name => 'restaurants',:uri=>'http://kalinda.us/ns/Restaurants',
                     :code=>'REST', :parent => cuisine, :creator => phoebe)


 health = Tag.find_or_create_by_name(:name => 'health',  :uri=>'http://kalinda.us/ns/Health',
                     :code=>'HEALTH', :description =>'Health and Beauty' )
 Tag.find_or_create_by_name(:name => 'spa',:uri=>'http://kalinda.us/ns/Spa', :parent => health,
                     :code=>'SPA', :creator => phoebe)
 Tag.find_or_create_by_name(:name => 'yoga/resort',:uri=>'http://kalinda.us/ns/Resort', :parent => health,
                     :code=>'YOGA', :creator => phoebe)

 family = Tag.find_or_create_by_name(:name => 'family',  :uri=>'http://kalinda.us/ns/Family',
                     :code=>'FAM', :description =>'Interesting for Families and Children' )
 Tag.find_or_create_by_name(:name => 'zoo',:uri=>'http://kalinda.us/ns/Zoo', :parent => family,
                     :code=>'ZOO', :creator => phoebe)
 Tag.find_or_create_by_name(:name => 'amusement park',:uri=>'http://kalinda.us/ns/Amusement_Park', :parent => family,
                     :code=>'AMUS', :creator => phoebe)

 Tag.find_or_create_by_name(:name => 'aquarium',:uri=>'http://kalinda.us/ns/Zoo', :parent => family,
                     :code=>'AQUA', :creator => phoebe)

 Tag.find_or_create_by_name(:name => 'hunting', :parent => outdoors, :code=>'HUNT', :uri=>'http://kalinda.us/ns/Hunt', :creator => phoebe)

 entertainment=Tag.find_or_create_by_name(:name => 'Evening Entertainment', :code=>'EVEN',:uri=>'http://kalinda.us/ns/Entertainment', :creator => phoebe)
 Tag.find_or_create_by_name(:name => 'casino', :parent => entertainment, :code=>'CASINO', :creator => phoebe)
 Tag.find_or_create_by_name(:name => 'Club', :parent => entertainment, :code=>'CLUB', :creator => phoebe)
 Tag.find_or_create_by_name(:name => 'theatre/opera', :parent => entertainment, :code=>'THEA', :creator => phoebe)
 Tag.find_or_create_by_name(:name => 'Live Music', :parent => entertainment, :code=>'MUS', :creator => phoebe)

 Tag.find_or_create_by_name(:name => 'archaeology', :parent => culture, :code=>'ARCHA', :creator => phoebe)
 Tag.find_or_create_by_name(:name => 'architecture', :parent => culture, :code=>'ARCHI', :creator => phoebe)

 festival= Tag.find_or_create_by_name(:name => 'Festival', :parent => culture, :code=>'FEST', :creator => phoebe)
 Tag.find_or_create_by_name(:name => 'Art Festival', :parent => festival, :code=>'ARTF', :creator => phoebe)
 Tag.find_or_create_by_name(:name => 'Music Festival', :parent => festival, :code=>'MUSF', :creator => phoebe)

 active = Tag.find_or_create_by_name(:name => 'Active', :code =>'ACT', :creator => phoebe)
 sport= Tag.find_or_create_by_name(:name => 'Sports', :parent => active, :code =>'SPORT', :creator => phoebe)
 water= Tag.find_or_create_by_name(:name => 'Watersports', :parent => active, :code =>'WATER', :creator => phoebe)
 Tag.find_or_create_by_name(:name => 'sailing', :parent => water, :code =>'SAIL', :creator => phoebe)
 Tag.find_or_create_by_name(:name => 'whitewater', :parent=> water, :code=>'WHITE', :creator => phoebe)
 Tag.find_or_create_by_name(:name => 'scuba', :parent => water, :code=>'SCUBA', :creator => phoebe)
 Tag.find_or_create_by_name(:name => 'snorkel', :parent => water, :code=>'SNORK', :creator => phoebe)
 Tag.find_or_create_by_name(:name => 'swimming', :parent => water, :code=>'SWIM', :creator => phoebe)
 Tag.find_or_create_by_name(:name => 'beach', :parent => outdoors, :code=>'BEACH', :creator => phoebe)
 Tag.find_or_create_by_name(:name => 'cave', :parent => sport, :code=>'CAVE', :creator => phoebe)
 Tag.find_or_create_by_name(:name => 'climbing', :parent=> sport, :code=>'CLIMB', :creator => phoebe)
 Tag.find_or_create_by_name(:name => 'skiing/Snowboarding', :parent => sport, :code =>'SKI', :creator => phoebe)
 Tag.find_or_create_by_name(:name => 'kayak/canoe', :parent => sport, :code=>'KAYAK', :creator => phoebe)
religious = Tag.find_or_create_by_name(:name => 'Religious', :parent => culture, :code =>'RELIC', :creator => phoebe)
 Tag.find_or_create_by_name(:name => 'church/temple', :parent => religious, :code=>'CHRH', :creator => phoebe)

# hiking trails -  www.wikiloc.com

