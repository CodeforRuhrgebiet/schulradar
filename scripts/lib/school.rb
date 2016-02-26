class School
  def initialize(open_data, doc)
    @open_data = open_data
    @doc = doc
  end

  def as_feature
    {
      type: 'Feature',
      geometry: {
        type: 'Point',
        coordinates: [coordinates[:long], coordinates[:lat]]
      },
      properties: {
        schulnummer: @doc.css('Schulnummer').children.text,
        schulbezeichnung: [
          @doc.css('Schulbezeichnung_1').children.text,
          @doc.css('Schulbezeichnung_2').children.text,
          @doc.css('Schulbezeichnung_3').children.text
        ].join("\n"),
        schulform: @open_data.schulform_by_key(@doc.css('Schulform').children.text),
        rechtsform: @open_data.rechtsform_by_key(@doc.css('Rechtsform').children.text),
        rechtsform_schluessel: @doc.css('Rechtsform').children.text,
        schultrager: @open_data.schultraeger_by_key(@doc.css('Traegernummer').children.text),
        schulbetrieb: @open_data.schulbetrieb_by_key(@doc.css('Schulbetriebsschluessel').children.text),
        schulbetrieb_schluessel: @doc.css('Schulbetriebsschluessel').children.text,
        gemeindeschluessel: @doc.css('Gemeindeschluessel').children.text,
        ort: @doc.css('Ort').children.text,
        strasse: @doc.css('Strasse').children.text,
        plz: @doc.css('PLZ').children.text,
        homepage: @doc.css('Homepage').children.text,
        schulbetriebsdatum: @doc.css('Schulbetriebsdatum').children.text
      }
    }
  end

  private

  def coordinates
    OpenDataStorage.calc_coordinates(@doc.css('KoordinatenRechtswert').children.text, @doc.css('KoordinatenHochwert').children.text)
  end
end
