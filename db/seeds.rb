# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

ron = User.find_or_create_by_login(:login => 'ron', :email => 'rnewman@thecia.net', 
   :password=>'ron', :email_confirmed => true, :latitude => 42.383, :longitude => -71.055) # Boston
phoebe = User.find_or_create_by_login(:login => 'phoebe',:email => 'phoebem@comcast.net', 
   :password=>'phoebe',:encrypted_password => 'crypted_password', :email_confirmed => true,
   :latitude => 37.7875, :longitude => -122.4138)  # San Francisco
kalinda = User.find_or_create_by_login(:login => 'kalinda',:email => 'kalinda@comcast.net', 
    :password=>'kalinda',:encrypted_password => 'crypted_password', :email_confirmed => true,
    :latitude => 47.6321, :longitude => -122.330)  # Seattle
steve = User.find_or_create_by_login(:login => 'steve',:email => 'steve@comcast.net', 
    :password=>'steve',:encrypted_password => 'crypted_password', :email_confirmed => true,
    :latitude => 30.295, :longitude => -97.741)  # Austin
grandpa = User.find_or_create_by_login(:login => 'grandpa',:email => 'grandpa@comcast.net', 
    :password=>'grandpa',:encrypted_password => 'crypted_password', :email_confirmed => true,
    :latitude => 40.7400, :longitude => -74.0025)  # NYC
grandma = User.find_or_create_by_login(:login => 'grandma',:email => 'grandma@comcast.net', 
    :password=>'grandma',:encrypted_password => 'crypted_password', :email_confirmed => true,
    :latitude => 40.7400, :longitude => -74.0025)  # NYC
blackie = User.find_or_create_by_login(:login => 'blackie',:email => 'blackie@comcast.net', 
    :password=>'blackie',:encrypted_password => 'crypted_password', :email_confirmed => true,
    :latitude => 35.7019, :longitude => -105.9370)  # Santa Fe


ACT=Tag.find_or_create_by_name(:name => 'ACT',
			:uri => 'http://kalinda.us/ns/ACT',
			:code => 'ACT',
			:id=> 1,
			:description=> "active")
KIDS=Tag.find_or_create_by_name(:name => 'KIDS',
			:uri => 'http://kalinda.us/ns/KIDS',
			:code => 'KIDS',
			:id=> 2,
			:description=> "suitable for kids under 18")
NIGHT=Tag.find_or_create_by_name(:name => 'NIGHT',
			:uri => 'http://kalinda.us/ns/NIGHT',
			:code => 'NIGHT',
			:id=> 3,
			:description=> "night time entertainment")
CULT=Tag.find_or_create_by_name(:name => 'CULT',
			:uri => 'http://kalinda.us/ns/CULT',
			:code => 'CULT',
			:id=> 4,
			:description=> "cultural interests")
ROM=Tag.find_or_create_by_name(:name => 'ROM',
			:uri => 'http://kalinda.us/ns/ROM',
			:code => 'ROM',
			:id=> 5,
			:description=> "romantic")
ADV=Tag.find_or_create_by_name(:name => 'ADV',
			:uri => 'http://kalinda.us/ns/ADV',
			:code => 'ADV',
			:id=> 6,
			:description=> "adventurous")
SCENE=Tag.find_or_create_by_name(:name => 'SCENE',
			:uri => 'http://kalinda.us/ns/SCENE',
			:code => 'SCENE',
			:id=> 7,
			:description=> "scenic")
RELAX=Tag.find_or_create_by_name(:name => 'RELAX',
			:uri => 'http://kalinda.us/ns/RELAX',
			:code => 'RELAX',
			:id=> 8,
			:description=> "relaxing")
HEALTH=Tag.find_or_create_by_name(:name => 'HEALTH',
			:uri => 'http://kalinda.us/ns/HEALTH',
			:code => 'HEALTH',
			:id=> 9,
			:description=> "health care, holistic,etc")
FOOD=Tag.find_or_create_by_name(:name => 'FOOD',
			:uri => 'http://kalinda.us/ns/FOOD',
			:code => 'FOOD',
			:id=> 10,
			:description=> "food and drink")
SWIM=Tag.find_or_create_by_name(:name => 'SWIM',
			:uri => 'http://kalinda.us/ns/SWIM',
			:code => 'SWIM',
			:id=> 11,
			:description=> "swim",:parent_id=> 1,
			:parent=> ACT)
DIVE=Tag.find_or_create_by_name(:name => 'DIVE',
			:uri => 'http://kalinda.us/ns/DIVE',
			:code => 'DIVE',
			:id=> 12,
			:description=> "snorkeling or scuba diving",:parent_id=> 1,
			:parent=> ACT)
HUNT=Tag.find_or_create_by_name(:name => 'HUNT',
			:uri => 'http://kalinda.us/ns/HUNT',
			:code => 'HUNT',
			:id=> 13,
			:description=> "Hunting",:parent_id=> 1,
			:parent=> ACT)
FISH=Tag.find_or_create_by_name(:name => 'FISH',
			:uri => 'http://kalinda.us/ns/FISH',
			:code => 'FISH',
			:id=> 14,
			:description=> "Fishing",:parent_id=> 1,
			:parent=> ACT)
HIKE=Tag.find_or_create_by_name(:name => 'HIKE',
			:uri => 'http://kalinda.us/ns/HIKE',
			:code => 'HIKE',
			:id=> 15,
			:description=> "Hiking or walking",:parent_id=> 1,
			:parent=> ACT)
BIKE=Tag.find_or_create_by_name(:name => 'BIKE',
			:uri => 'http://kalinda.us/ns/BIKE',
			:code => 'BIKE',
			:id=> 16,
			:description=> "Biking",:parent_id=> 1,
			:parent=> ACT)
CLIMB=Tag.find_or_create_by_name(:name => 'CLIMB',
			:uri => 'http://kalinda.us/ns/CLIMB',
			:code => 'CLIMB',
			:id=> 17,
			:description=> "Rock or Ice climbing",:parent_id=> 1,
			:parent=> ACT)
ARCHIT=Tag.find_or_create_by_name(:name => 'ARCHIT',
			:uri => 'http://kalinda.us/ns/ARCHIT',
			:code => 'ARCHIT',
			:id=> 18,
			:description=> "architecture",:parent_id=> 4,
			:parent=> CULT)
ARCHAE=Tag.find_or_create_by_name(:name => 'ARCHAE',
			:uri => 'http://kalinda.us/ns/ARCHAE',
			:code => 'ARCHAE',
			:id=> 19,
			:description=> "archaelogy",:parent_id=> 4,
			:parent=> CULT)
HIST=Tag.find_or_create_by_name(:name => 'HIST',
			:uri => 'http://kalinda.us/ns/HIST',
			:code => 'HIST',
			:id=> 20,
			:description=> "history",:parent_id=> 4,
			:parent=> CULT)
SKI=Tag.find_or_create_by_name(:name => 'SKI',
			:uri => 'http://kalinda.us/ns/SKI',
			:code => 'SKI',
			:id=> 21,
			:description=> "ski,snowboard",:parent_id=> 1,
			:parent=> ACT)
BOAT=Tag.find_or_create_by_name(:name => 'BOAT',
			:uri => 'http://kalinda.us/ns/BOAT',
			:code => 'BOAT',
			:id=> 22,
			:description=> "kayak,canoe,whitewater,surf,sail",:parent_id=> 1,
			:parent=> ACT)
ART=Tag.find_or_create_by_name(:name => 'ART',
			:uri => 'http://kalinda.us/ns/ART',
			:code => 'ART',
			:id=> 23,
			:description=> "visual or performance art",:parent_id=> 4,
			:parent=> CULT)
SCI=Tag.find_or_create_by_name(:name => 'SCI',
			:uri => 'http://kalinda.us/ns/SCI',
			:code => 'SCI',
			:id=> 24,
			:description=> "science",:parent_id=> 4,
			:parent=> CULT)
RELIG=Tag.find_or_create_by_name(:name => 'RELIG',
			:uri => 'http://kalinda.us/ns/RELIG',
			:code => 'RELIG',
			:id=> 25,
			:description=> "religion",:parent_id=> 4,
			:parent=> CULT)
MUSIC=Tag.find_or_create_by_name(:name => 'MUSIC',
			:uri => 'http://kalinda.us/ns/MUSIC',
			:code => 'MUSIC',
			:id=> 26,
			:description=> "music",:parent_id=> 4,
			:parent=> CULT)
MARTIA=Tag.find_or_create_by_name(:name => 'MARTIA',
			:uri => 'http://kalinda.us/ns/MARTIA',
			:code => 'MARTIA',
			:id=> 27,
			:description=> "martial arts",:parent_id=> 1,
			:parent=> ACT)
OUT=Tag.find_or_create_by_name(:name => 'OUT',
			:uri => 'http://kalinda.us/ns/OUT',
			:code => 'OUT',
			:id=> 101,
			:description=> "Outdoors")
MUSEUM=Tag.find_or_create_by_name(:name => 'MUSEUM',
			:uri => 'http://kalinda.us/ns/MUSEUM',
			:code => 'MUSEUM',
			:id=> 102,
			:description=> "Museum")
FOOD=Tag.find_or_create_by_name(:name => 'FOOD',
			:uri => 'http://kalinda.us/ns/FOOD',
			:code => 'FOOD',
			:id=> 103,
			:description=> "Food producers or restaurants")
ENTER=Tag.find_or_create_by_name(:name => 'ENTER',
			:uri => 'http://kalinda.us/ns/ENTER',
			:code => 'ENTER',
			:id=> 104,
			:description=> "Entertainments")
RESORT=Tag.find_or_create_by_name(:name => 'RESORT',
			:uri => 'http://kalinda.us/ns/RESORT',
			:code => 'RESORT',
			:id=> 105,
			:description=> "Resorts")
ACCOM=Tag.find_or_create_by_name(:name => 'ACCOM',
			:uri => 'http://kalinda.us/ns/ACCOM',
			:code => 'ACCOM',
			:id=> 106,
			:description=> "Accommodations")
SHOP=Tag.find_or_create_by_name(:name => 'SHOP',
			:uri => 'http://kalinda.us/ns/SHOP',
			:code => 'SHOP',
			:id=> 107,
			:description=> "Shopping")
SERV=Tag.find_or_create_by_name(:name => 'SERV',
			:uri => 'http://kalinda.us/ns/SERV',
			:code => 'SERV',
			:id=> 108,
			:description=> "Services such as Salon,Spa or Massage")
CONF=Tag.find_or_create_by_name(:name => 'CONF',
			:uri => 'http://kalinda.us/ns/CONF',
			:code => 'CONF',
			:id=> 109,
			:description=> "Conference space")
HOSP=Tag.find_or_create_by_name(:name => 'HOSP',
			:uri => 'http://kalinda.us/ns/HOSP',
			:code => 'HOSP',
			:id=> 110,
			:description=> "Hospital or clinic")
PARK=Tag.find_or_create_by_name(:name => 'PARK',
			:uri => 'http://kalinda.us/ns/PARK',
			:code => 'PARK',
			:id=> 111,
			:description=> "National ,State or Local Park or Reservations",:parent_id=> 101,
			:parent=> OUT)
GARDEN=Tag.find_or_create_by_name(:name => 'GARDEN',
			:uri => 'http://kalinda.us/ns/GARDEN',
			:code => 'GARDEN',
			:id=> 112,
			:description=> "Botanical,Public gardens or Zoo",:parent_id=> 101,
			:parent=> OUT)
AMUSE=Tag.find_or_create_by_name(:name => 'AMUSE',
			:uri => 'http://kalinda.us/ns/AMUSE',
			:code => 'AMUSE',
			:id=> 113,
			:description=> "Amusement park, Water Park, Miniature golf, Paintball etc ",:parent_id=> 101,
			:parent=> OUT)
WILD=Tag.find_or_create_by_name(:name => 'WILD',
			:uri => 'http://kalinda.us/ns/WILD',
			:code => 'WILD',
			:id=> 114,
			:description=> "Wilderness or BLM land",:parent_id=> 101,
			:parent=> OUT)
BEACH=Tag.find_or_create_by_name(:name => 'BEACH',
			:uri => 'http://kalinda.us/ns/BEACH',
			:code => 'BEACH',
			:id=> 115,
			:description=> "Beach or water front",:parent_id=> 101,
			:parent=> OUT)
WATER=Tag.find_or_create_by_name(:name => 'WATER',
			:uri => 'http://kalinda.us/ns/WATER',
			:code => 'WATER',
			:id=> 116,
			:description=> "River, Lake, Coast, etc",:parent_id=> 101,
			:parent=> OUT)
TRL=Tag.find_or_create_by_name(:name => 'TRL',
			:uri => 'http://kalinda.us/ns/TRL',
			:code => 'TRL',
			:id=> 117,
			:description=> "Hiking trails",:parent_id=> 101,
			:parent=> OUT)
ART=Tag.find_or_create_by_name(:name => 'ART',
			:uri => 'http://kalinda.us/ns/ART',
			:code => 'ART',
			:id=> 120,
			:description=> "Art museum",:parent_id=> 102,
			:parent=> MUSEUM)
SCI=Tag.find_or_create_by_name(:name => 'SCI',
			:uri => 'http://kalinda.us/ns/SCI',
			:code => 'SCI',
			:id=> 121,
			:description=> "Science,Natural History or Geology Museum",:parent_id=> 102,
			:parent=> MUSEUM)
CULT=Tag.find_or_create_by_name(:name => 'CULT',
			:uri => 'http://kalinda.us/ns/CULT',
			:code => 'CULT',
			:id=> 122,
			:description=> "History or religious museum",:parent_id=> 102,
			:parent=> MUSEUM)
REST=Tag.find_or_create_by_name(:name => 'REST',
			:uri => 'http://kalinda.us/ns/REST',
			:code => 'REST',
			:id=> 123,
			:description=> "Restaurant, Cafe,or just serves food",:parent_id=> 103,
			:parent=> FOOD)
DRINK=Tag.find_or_create_by_name(:name => 'DRINK',
			:uri => 'http://kalinda.us/ns/DRINK',
			:code => 'DRINK',
			:id=> 124,
			:description=> "Brewery,Bar,Winery etc",:parent_id=> 103,
			:parent=> FOOD)
CASINO=Tag.find_or_create_by_name(:name => 'CASINO',
			:uri => 'http://kalinda.us/ns/CASINO',
			:code => 'CASINO',
			:id=> 125,
			:description=> "Casino",:parent_id=> 104,
			:parent=> ENTER)
FEST=Tag.find_or_create_by_name(:name => 'FEST',
			:uri => 'http://kalinda.us/ns/FEST',
			:code => 'FEST',
			:id=> 126,
			:description=> "Festivals",:parent_id=> 104,
			:parent=> ENTER)
CLUB=Tag.find_or_create_by_name(:name => 'CLUB',
			:uri => 'http://kalinda.us/ns/CLUB',
			:code => 'CLUB',
			:id=> 127,
			:description=> "Bar, dance club or places with live music",:parent_id=> 104,
			:parent=> ENTER)
SPORT=Tag.find_or_create_by_name(:name => 'SPORT',
			:uri => 'http://kalinda.us/ns/SPORT',
			:code => 'SPORT',
			:id=> 128,
			:description=> "Sports stadiums or facility",:parent_id=> 104,
			:parent=> ENTER)
SHOW=Tag.find_or_create_by_name(:name => 'SHOW',
			:uri => 'http://kalinda.us/ns/SHOW',
			:code => 'SHOW',
			:id=> 129,
			:description=> "Opera, Theatre, Concert hall, Ballet, Playhouse or other places for watching live performances",:parent_id=> 104,
			:parent=> ENTER)
HOTEL=Tag.find_or_create_by_name(:name => 'HOTEL',
			:uri => 'http://kalinda.us/ns/HOTEL',
			:code => 'HOTEL',
			:id=> 118,
			:description=> "Hotel,Motel or B&B",:parent_id=> 106,
			:parent=> ACCOM)
CAMP=Tag.find_or_create_by_name(:name => 'CAMP',
			:uri => 'http://kalinda.us/ns/CAMP',
			:code => 'CAMP',
			:id=> 119,
			:description=> "Cabin,Tent,Rv park",:parent_id=> 106,
			:parent=> ACCOM)
MALL=Tag.find_or_create_by_name(:name => 'MALL',
			:uri => 'http://kalinda.us/ns/MALL',
			:code => 'MALL',
			:id=> 130,
			:description=> "Mall",:parent_id=> 107,
			:parent=> SHOP)
OUTLET=Tag.find_or_create_by_name(:name => 'OUTLET',
			:uri => 'http://kalinda.us/ns/OUTLET',
			:code => 'OUTLET',
			:id=> 131,
			:description=> "Outlets",:parent_id=> 107,
			:parent=> SHOP)
SPA=Tag.find_or_create_by_name(:name => 'SPA',
			:uri => 'http://kalinda.us/ns/SPA',
			:code => 'SPA',
			:id=> 132,
			:description=> "Spa",:parent_id=> 108,
			:parent=> SERV)
CRUISE=Tag.find_or_create_by_name(:name => 'CRUISE',
			:uri => 'http://kalinda.us/ns/CRUISE',
			:code => 'CRUISE',
			:id=> 133,
			:description=> "Cruise",:parent_id=> 105,
			:parent=> RESORT)




# hiking trails -  www.wikiloc.com

Profile.find_or_create_by_name_and_user_id(:name => 'work travel',:user=>phoebe, :description => 'Preferences for work related travelling'); 
phoebeprofile= Profile.find_or_create_by_name_and_user_id(:name => 'family travel',:user=>phoebe, :description => 'Family travel'); 
kprofile = Profile.find_or_create_by_name_and_user_id(:name => 'travel',:user=>kalinda ); 
steveprofile= Profile.find_or_create_by_name_and_user_id(:name => 'family travel',:user=>steve ); 
grandmaprofile= Profile.find_or_create_by_name_and_user_id(:name => 'general',:user=>grandma ); 
grandpaprofile= Profile.find_or_create_by_name_and_user_id(:name => 'general',:user=>grandpa ); 
kprofile.update_attributes({ :tag_ids =>[KIDS.id.to_s, OUT.id.to_s, MUSEUM.id.to_s, BEACH.id.to_s, SKI.id.to_s, SWIM.id.to_s] })
grandpaprofile.update_attributes({ :tag_ids =>[FOOD.id.to_s, FISH.id.to_s, MUSEUM.id.to_s, RELIG.id.to_s] })
