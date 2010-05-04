require 'rubygems'
require 'mechanize'
require 'active_support'
require 'nokogiri'
require 'open-uri'
require 'geocoder'
require 'importer'
require 'yellowpages'
require 'scraper'


class Seasons 
  def initialize
    @importer= Importer.new
  end

  def setSeason 
    :summer => [5,6,7,8]
    :winter_holiday =>[12]
    :winter =>[1,2,3]
    :spring =>[4,5,6]
  end

end
