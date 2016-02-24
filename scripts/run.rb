#!/usr/bin/ruby

require 'nokogiri'
require 'json'
require 'open-uri'

Dir['./lib/*.rb'].each {|file| require file }

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
city_store.cities.each { |city| city.save_to_file! }

puts 'DONE!!! :)'
exit







## Rechtsformen
@rechtsformen = false
@key_rechtsform_file = 'https://www.schulministerium.nrw.de/BiPo/OpenData/Schuldaten/key_rechtsform.xml'

def get_rechtsform_by_key(key)
  @rechtsformen[key]
end

def set_rechtsformen!
  rechtsformen = {}
  raw = open(@key_rechtsform_file)
  doc = Nokogiri::XML(raw)
  doc.search('//Rechtsform').each do |rechtsform|
    rechtsformen["#{rechtsform.css("Schluessel").children.text}"] = rechtsform.css("Bezeichnung").children.text
  end

  @rechtsformen = rechtsformen
end
set_rechtsformen!


## Schulformen
@schulformen = false
@key_schulformschluessel_file = 'https://www.schulministerium.nrw.de/BiPo/OpenData/Schuldaten/key_schulformschluessel.xml'

def get_schulform_by_key(key)
  @schulformen[key]
end

def set_schulformen!
  schulformen = {}
  raw = open(@key_schulformschluessel_file)
  doc = Nokogiri::XML(raw)
  doc.search('//Schulform').each do |schulform|
    schulformen["#{schulform.css("Schluessel").children.text}"] = schulform.css("Bezeichnung").children.text
  end

  @schulformen = schulformen
end
set_schulformen!

## Schulträger
@schultraeger = false
@key_traeger_file = 'https://www.schulministerium.nrw.de/BiPo/OpenData/Schuldaten/key_traeger.xml'

def get_schultraeger_by_key(key)
  @schultraeger[key]
end

def set_schultraeger!
  schultraeger_list = {}
  raw = open(@key_traeger_file)
  doc = Nokogiri::XML(raw)
  doc.search('//Traeger').each do |schultraeger|
    schultraeger_list["#{schultraeger.css("Traegernummer").children.text}"] = schultraeger.css("Traegerbezeichnung_1").children.text
  end

  @schultraeger = schultraeger_list
end
set_schultraeger!

## Schulbetriebe
@schulbetriebe = false
@key_schulbetriebsschluessel_file = 'https://www.schulministerium.nrw.de/BiPo/OpenData/Schuldaten/key_schulbetriebsschluessel.xml'

def get_schulbetrieb_by_key(key)
  @schulbetriebe[key]
end

def set_schulbetriebe!
  schulbetriebe = {}
  raw = open(@key_schulbetriebsschluessel_file)
  doc = Nokogiri::XML(raw)
  doc.search('//Schulbetrieb').each do |schulbetrieb|
    schulbetriebe["#{schulbetrieb.css("Schluessel").children.text}"] = schulbetrieb.css("Bezeichnung").children.text
  end

  @schulbetriebe = schulbetriebe
end
set_schulbetriebe!

save_to_file!('./dist/schulen.geojson', object)
puts 'DONE!! :)'
