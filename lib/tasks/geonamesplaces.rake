
namespace :mysql do
  desc 'load into mysql geonames'
  task :geonamesplaces do
    sh %{ echo 'load geonames places'; }
    sh %{ gzip -cd  db/data/places3.sql.gz > /tmp/places3.sql  }
    sh %{ cat tmp/places3.sql | mysql geonames }
    sh %{ echo 'rename table places3 to places' | mysql geonames }
  end

end
