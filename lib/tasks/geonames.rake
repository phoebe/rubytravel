namespace :mysql do
  desc 'load into mysql geonames'
  task :geonames do
    sh %{ echo 'load geonames '; }
    sh %{ cp -f db/data/features.txt /tmp; }
    sh %{ mysqlimport -d -r -uroot --fields-terminated-by="\t" --verbose --default-character-set=utf8 geonames /tmp/features.txt; }
    sh %{  cp -f db/data/countryInfo.txt /tmp; }
    sh %{ mysqlimport -d -u root  --ignore-lines 42  --fields-terminated-by="\t" --verbose --default-character-set=utf8 geonames /tmp/countryInfo.txt }
    sh %{  cp -f db/data/cities1000.txt /tmp/cities.txt; }
    sh %{ mysqlimport -d -u root --fields-terminated-by="\t" --verbose --default-character-set=utf8 geonames /tmp/cities.txt }
    sh %{ echo 'create index cities_latlng on cities(latitude,longitude)'| mysql geonames }
    sh %{ echo 'create index cities_name on cities(name)'| mysql geonames }
  end

end
