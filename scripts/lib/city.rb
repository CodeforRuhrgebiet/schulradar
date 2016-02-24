class City
  def initialize(open_data, city_values)
    @open_data = open_data
    @name = city_values[:name]
    puts "# Initializing City: #{@name}"
    @postcodes = city_values[:postcodes]
    @schools = []
  end

  def fetch_schools!
    raw = @open_data.read_file('schuldaten.xml')
    doc = Nokogiri::XML(raw)
    xml_schools = doc.search('//Schule')
    school_count = xml_schools.size
    xml_schools.each_with_index do |school, index|
      puts "Searching for relevant Schools (#{index+1}/#{school_count})"
      if within_postcode?(school.css('PLZ').children.text)
        s = School.new(@open_data, school)
        @schools.push(s.as_feature)
      end
    end
  end

  def save_to_file!
    destination_path = "./dist/#{@name.downcase}.geojson"

    data = {
      type: 'FeatureCollection',
      features: @schools
    }

    puts "Saving data into #{destination_path} ..."
    File.open(destination_path, 'w') do |file|
      file.print data.to_json
    end
  end

  private

  def within_postcode?(postcode)
    @postcodes.include?(postcode)
  end
end
