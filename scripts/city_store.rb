class CityStore
  def initialize
    @cities = []
  end

  def add_city(city)
    @cities.push(city)
  end

  def cities
    @cities
  end
end
