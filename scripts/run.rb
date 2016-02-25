#!/usr/bin/ruby

require 'nokogiri'
require 'json'
require 'open-uri'
require 'erb'

@@project_root = File.expand_path('..', File.dirname(__FILE__))
Dir["#{@@project_root}/scripts/lib/*.rb"].each {|file| require file }

# Config
city_values = [
  {
    name: 'Essen',
    postcodes: %w(45127 45128 45130 45131 45133 45134 45136 45138 45139 45141 45143 45144 45145 45147 45149 45219 45239 45257 45259 45276 45277 45279 45289 45307 45309 45326 45327 45329 45355 45356 45357 45359)
  }
]

# Logic
open_data = OpenDataStorage.new
open_data.fetch_all_requirements!

city_store = CityStore.new
city_values.each { |cv| city_store.add_city(City.new(open_data, cv)) }
city_store.cities.each { |city| city.fetch_schools! }
city_store.cities.each { |city| city.save_to_files! }

puts 'DONE!!! :)'
exit
