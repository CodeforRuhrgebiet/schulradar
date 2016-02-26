class OpenDataStorage
  def self.calc_coordinates(east, north)
    # puts "=> getting coordinates.. (Rechtswert:#{east}, Hochwert:#{north})"
    east = east.to_s[0...7]
    north = north.to_s[0...7]
    output = []
    p = IO.popen("python #{@@project_root}/scripts/calc_coordinates.py #{east} #{north}")
    p.each { |line| output << line.chomp }
    p.close
    {lat: output[0].to_f, long: output[1].to_f}
  end

  # Instance Methods
  def initialize
    @storage_dir = "#{@@project_root}/scripts/.opendata"
    @requirements = [
      {
        url: 'https://www.schulministerium.nrw.de/BiPo/OpenData/Schuldaten/key_rechtsform.xml',
        local: 'key_rechtsform.xml'
      },
      {
        url: 'https://www.schulministerium.nrw.de/BiPo/OpenData/Schuldaten/key_schulformschluessel.xml',
        local: 'key_schulformschluessel.xml'
      },
      {
        url: 'https://www.schulministerium.nrw.de/BiPo/OpenData/Schuldaten/key_traeger.xml',
        local: 'key_traeger.xml'
      },
      {
        url: 'https://www.schulministerium.nrw.de/BiPo/OpenData/Schuldaten/key_schulbetriebsschluessel.xml',
        local: 'key_schulbetriebsschluessel.xml'
      },
      {
        url: 'https://www.schulministerium.nrw.de/BiPo/OpenData/Schuldaten/schuldaten.xml',
        local: 'schuldaten.xml'
      },
      {
        url: 'http://www.fa-technik.adfc.de/code/opengeodb/PLZ.tab',
        local: 'PLZ.tab'
      }
    ]

    @rechtsformen = false
    parse_rechtsformen!

    @schulformen = false
    parse_schulformen!

    @schultraeger = false
    parse_schultraeger!

    @schulbetriebe = false
    parse_schulbetriebe!

    @city_postcodes = {}
    @postcode_schools = {}
    map_schools_to_postcodes!
  end

  def fetch_all_requirements!
    @requirements.each_with_index do |requirement, i|
      puts "Fetching #{i + 1}/#{@requirements.size}"
      url = requirement[:url]
      dest_path = [@storage_dir, requirement[:local]].join('/')
      puts "=> writing #{dest_path} ..."
      File.open(dest_path, 'wb') do |saved_file|
        open(url, 'rb') do |read_file|
          saved_file.write(read_file.read)
        end
      end
    end
  end

  def process_data!
    map_postcodes_to_city!
  end

  def read_file(name)
    File.read([@storage_dir, name].join('/'))
  end

  def rechtsform_by_key(key)
    #@rechtsformen[key]
    case key
      when '1'
        'öffentlich'
      when "2"
        'privat'
      else
        puts 'unbekannt'
    end
  end

  def schulform_by_key(key)
    @schulformen[key]
  end

  def schultraeger_by_key(key)
    @schultraeger[key]
  end

  def schulbetrieb_by_key(key)
    @schulbetriebe[key]
  end

  def city_postcodes_by_key(key)
    @city_postcodes[key]
  end

  def schools_by_postcode(postcode)
    @postcode_schools[postcode]
  end

  private

  # Setter
  def parse_rechtsformen!
    rechtsformen = {}
    raw = read_file('key_rechtsform.xml')
    doc = Nokogiri::XML(raw)
    doc.search('//Rechtsform').each do |rechtsform|
      rechtsformen["#{rechtsform.css("Schluessel").children.text}"] = rechtsform.css("Bezeichnung").children.text
    end

    @rechtsformen = rechtsformen
  end

  def parse_schulformen!
    schulformen = {}
    raw = read_file('key_schulformschluessel.xml')
    doc = Nokogiri::XML(raw)
    doc.search('//Schulform').each do |schulform|
      schulformen["#{schulform.css("Schluessel").children.text}"] = schulform.css("Bezeichnung").children.text
    end

    @schulformen = schulformen
  end

  def parse_schultraeger!
    schultraeger_list = {}
    raw = read_file('key_traeger.xml')
    doc = Nokogiri::XML(raw)
    doc.search('//Traeger').each do |schultraeger|
      schultraeger_list["#{schultraeger.css("Traegernummer").children.text}"] = schultraeger.css("Traegerbezeichnung_1").children.text
    end

    @schultraeger = schultraeger_list
  end

  def parse_schulbetriebe!
    schulbetriebe = {}
    raw = read_file('key_schulbetriebsschluessel.xml')
    doc = Nokogiri::XML(raw)
    doc.search('//Schulbetrieb').each do |schulbetrieb|
      schulbetriebe["#{schulbetrieb.css("Schluessel").children.text}"] = schulbetrieb.css("Bezeichnung").children.text
    end

    @schulbetriebe = schulbetriebe
  end

  def map_postcodes_to_city!
    file_entries = CSV.read([@storage_dir, 'PLZ.tab'].join('/'), { :col_sep => "\t" })
    file_entries.each do |entry|
      @city_postcodes["#{entry[4]}"] = [] if !@city_postcodes["#{entry[4]}"]
      @city_postcodes["#{entry[4]}"].push("#{entry[1]}")
    end
  end

  def map_schools_to_postcodes!
    puts 'Mapping schools to postcodes..'.green
    raw = read_file('schuldaten.xml')
    doc = Nokogiri::XML(raw)
    xml_schools = doc.search('//Schule')
    xml_schools.each do |school|
      school_postcode = school.css('PLZ').children.text
      @postcode_schools["#{school_postcode}"] = [] if !@postcode_schools["#{school_postcode}"]
      @postcode_schools["#{school_postcode}"].push(school)
    end
    puts '=> finished mapping schools to postcodes!'
  end
end
