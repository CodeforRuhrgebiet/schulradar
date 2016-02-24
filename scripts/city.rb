class City
  def self.print_all_cities
    puts @@cities
    puts 'it works!'
  end

  # Instance Functions
  def initialize(city_values)
    @name = city_values[:name]
    puts "# Initializing City: #{@name}"

    @postcodes = city_values[:postcodes]
    fetch_schools!
  end

  def hello
    puts 'HELLO!!!'
  end

  def locations
  end

  private

  def fetch_schools!
    puts '=> this method gets all schools that match the postcodes for this city and are stored in the object'
  end
end
