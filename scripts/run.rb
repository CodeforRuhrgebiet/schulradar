#!/usr/bin/ruby

require 'nokogiri'
require 'yaml'
require 'csv'
require 'json'
require 'open-uri'
require 'erb'
require 'colorize'

@@project_root = File.expand_path('..', File.dirname(__FILE__))
Dir["#{@@project_root}/scripts/lib/*.rb"].each {|file| require file }
script_start_time = Time.now


# Logic
open_data = OpenDataStorage.new

# uncomment the following line to update the open data files
#open_data.fetch_all_requirements!
open_data.process_data!

city_store = CityStore.new
City.supported_cities.each { |cv| city_store.add_city(City.new(open_data, cv)) }
city_store.cities.each { |city| city.fetch_schools_from_postcode! }
city_store.cities.each { |city| city.save_to_files! }

puts 'DONE!!! :)'.blue
script_end_time = Time.now
delta = script_end_time - script_start_time
puts "This operation took #{delta} seconds which are #{(delta / 60).round(2)} minutes.".light_cyan

exit
