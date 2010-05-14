
namespace :mysql do
  desc 'load into mysql geonames'
  task :geonamesplaces do
    sh %{ echo 'load geonames places'; }
    sh %{ gzip -cd  db/data/places2.sql.gz > /tmp/places2.sql.gz  }
    sh %{ cat db/data/places2tbl.sql | mysql geonames }
    sh %{ mysqlimport -u root --verbose --default-character-set=utf8 geonames /tmp/places2.sql }
    sh %{ echo 'rename table places2 to places' | mysql geonames }
    sh %{ echo 'drop table places2' | mysql geonames }
  end

end
