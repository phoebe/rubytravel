
namespace :mysql do
  desc 'load into mysql geonames'
  task :geonamesplaces do
    sh %{ echo 'load geonames places'; }
    sh %{ gzip -cd  db/data/places2.sql.gz > /tmp/places2.sql  }
    sh %{ cat tmp/places2.sql | mysql geonames }
    sh %{ echo 'rename table places2 to places' | mysql geonames }
  end

end
