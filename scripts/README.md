# Schulradar Data Collector

## Initial setup

Make sure __*ruby*__ and __*python*__ are installed.

```bash
$ git clone git@github.com:CodeforRuhrgebiet/schulradar-data-collector.git
```

```bash
$ cd schulradar-data-collector
```

```bash
$ git submodule init && git submodule update
```

```bash
$ bundle install
```

## Generating GeoJSON

Run the following script

`ruby run.rb`

this will take a while. When it's finished there will be a new file called `dist/schulen.geojson`.
