require 'nokogiri'
require 'json'
require 'open-uri'

@cities = [
  {
    name: "Essen",
    postcodes: [
      '45127', '45128', '45130', '45131', '45133', '45134',
      '45136', '45138', '45139', '45141', '45143', '45144',
      '45145', '45147', '45149', '45219', '45239', '45257',
      '45259', '45276', '45277', '45279', '45289', '45307',
      '45309', '45326', '45327', '45329', '45355', '45356',
      '45357', '45359'
    ]
  }
]

def included_city?(postcode)
  found_postcode = false
  @cities.each do |city|
    if city[:postcodes].include?(postcode)
      found_postcode = true
      break
    end
  end
  found_postcode ? true : false
end

# calc stuff
def calc_coordinates(east, north)
  puts "=> getting coordinates.."
  east = east.to_s[0...7]
  north = north.to_s[0...7]
  output = []
  p = IO.popen("python ./calc_coordinates.py #{east} #{north}")
  p.each { |line| output << line.chomp }
  p.close
  {lat: output[0].to_f, long: output[1].to_f}
end

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


## Schulen
@schulen = false
@schuldaten_file = 'https://www.schulministerium.nrw.de/BiPo/OpenData/Schuldaten/schuldaten.xml'

def schuldaten_as_geojson_features
  puts "Fetching schools.."
  schools = []
  #data = File.open("schuldaten_test.xml").read
  data = open(@schuldaten_file)

  doc = Nokogiri::XML(data)
  xml_schools = doc.search('//Schule')
  school_count = xml_schools.size
  xml_schools.each_with_index do |schule, index|
    puts "School #{index+1}/#{school_count}"
    if included_city?(schule.css("PLZ").children.text)
      coordinates = calc_coordinates(schule.css("KoordinatenRechtswert").children.text, schule.css("KoordinatenHochwert").children.text)
      feature = {
        type: 'Feature',
        geometry: {
          type: 'Point',
          coordinates: [coordinates[:long], coordinates[:lat]]
        },
        properties: {
          schulnummer: schule.css("Schulnummer").children.text,
          schulbezeichnung: [
            schule.css("Schulbezeichnung_1").children.text,
            schule.css("Schulbezeichnung_2").children.text,
            schule.css("Schulbezeichnung_3").children.text
            ].join,
          schulform: get_schulform_by_key(schule.css("Schulform").children.text),
          rechtsform: get_rechtsform_by_key(schule.css("Rechtsform").children.text),
          schultrager: get_schultraeger_by_key(schule.css("Traegernummer").children.text),
          gemeindeschluessel: schule.css("Gemeindeschluessel").children.text,
          schulbetrieb: get_schulbetrieb_by_key(schule.css("Schulbetriebsschluessel").children.text),
          plz: schule.css("PLZ").children.text
        }
      }
      schools.push(feature)
    else
      puts "=> school not in specified location"
    end
  end

  schools
end

def save_to_file!(filename, data)
  puts "Saving data into #{filename}.."
  File.open(filename, 'w') do |file|
    file.print data.to_json
  end
end

object = obj = {
  type: 'FeatureCollection',
  features: schuldaten_as_geojson_features
}

save_to_file!('./dist/schulen.geojson', object)
puts 'DONE!! :)'
