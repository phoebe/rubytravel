# -*- coding: utf-8 -*-

class GeonameDB < ActiveRecord::Base
  self.establish_connection(:geonames)
  self.abstract_class = true 
end
