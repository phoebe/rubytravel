require 'rubygems'
require 'yahoo/geocode'

application_id= "6.s3T.nV34E7G_DUQbuiiTN9Ca7waeaW0E9apk5eM5rTb13FxwVJM9bYTa5ePqvvbFM-";

yg = Yahoo::Geocode.new application_id
locations = yg.locate '701 First Street, Sunnyvale, CA'
p location.first.coordinates
