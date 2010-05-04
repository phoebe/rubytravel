require "mysql"
# m = Mysql.new('localhost', 'phoebe', '', 'geonames')
m = Mysql.init;
m.real_connect("127.0.0.1", "phoebe", "", "geonames",3306,nil,Mysql::CLIENT_MULTI_RESULTS)


m.list_tables.each do |table|
    puts table
    m.list_fields(table).fetch_fields.each do |f|
        puts "\t"+f.name
    end
end

def getprox(m)
  m.query_with_result=false
  res = m.query("call geonames.withinRadius(37,120,10);");
  begin
    res = m.use_result
      rescue Mysql::Error => e 
          no_more_results=true
  end 
    colcount=res.fetch_fields.size
    printf " got %d fields ", colcount;
    #
    #printf " got %d results ", res.size;
  fields = res.fetch_fields.each do |f|
    puts f.name
  end
  puts fields.join("\t")
  res.each do |row|
      puts row.join("\t")
  end
end

def getfeatures(m)
  res = m.query("select * from features limit 5")
  res.each do |row|
      puts row.join("\t")
  end
end

getprox(m);

def getadmin1() 
  m = Mysql.new("localhost", "phoebe", "")
  m.select_db("geonames")
  result = m.query("SELECT * FROM admin1 limit 2")
  result.each_hash do |h|
        printf("%-12s %-12s %-12s\n", h['code'], h['name'], h['geonameid'])
  end
end

def countryInfo() 
  result = m.query("SELECT * FROM countryInfo limit 2 ")
  result.each_hash do |h|
      h.each do |key, value|
            printf("%-12s %-12s\n", key, value)
              end
  end
end


def features() 
  res = m.query("select * from features limit 5")
  res.each do |row|
      puts row.join("\t")
  end
end
m.close
