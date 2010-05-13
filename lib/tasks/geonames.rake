namespace :mysql do
  desc 'load into mysql geonames'
  task :geonames do
    sh %{ echo 'load geonames '; }
    sh %{ cp -f db/data/features.txt /tmp; }
    sh %{ mysqlimport -d -r -uroot --fields-terminated-by="\t" --verbose --default-character-set=utf8 geonames /tmp/features.txt; }
    sh %{  cp -f db/data/countryInfo.txt /tmp; }
    sh %{ mysqlimport -d -u root  --ignore-lines 42  --fields-terminated-by="\t" --verbose --default-character-set=utf8 geonames /tmp/countryInfo.txt }
    sh %{  cp -f db/data/allCountries.txt /tmp; }
    sh %{ mysqlimport -d -u root  --fields-terminated-by="\t" --verbose --default-character-set=utf8 geonames /tmp/allCountries.txt }
    sh %{  gzip -d db/data/db/data/places_sample_dump.sql.gz  }
    sh %{  cp -f db/data/places_sample_dump.sql /tmp; }
    sh %{ mysqlimport -d -u root  --fields-terminated-by="\t" --verbose --default-character-set=utf8 geonames /tmp/places_sample_dump.sql }
    sh %{ mysql geonames < echo 'rename table places2 to places' }
  end

end
