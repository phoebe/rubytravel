namespace :mysql do
  desc 'load into mysql geonames'
  task :geonames do
    sh %{ echo 'load geonames '; }
    sh %{ mysqlimport -d -r -u root  --fields-terminated-by="\t" --verbose --default-character-set=utf8 geonames db/data/features.txt; }
    sh %{ mysqlimport -d -u root  --fields-terminated-by="\t" --verbose --default-character-set=utf8 geonames db/data/allCountries.txt }
    sh %{ mysqlimport -d -u root --v --ignore-lines 42  --fields-terminated-by="\t" --verbose --default-character-set=utf8 geonames db/data/countryInfo.txt }
  end
end
