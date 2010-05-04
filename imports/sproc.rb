require 'yellowpages'
require 'geocoder'
require 'mysql'
require 'logger'
require 'active_support'
require 'net/http'
require 'uri'

class TestSP
  def initialize()
    $log = Logger.new("log.#{$0}.txt",'daily') if $log.nil?
    begin
  #####   NOTE THE CLIENT_MULTI_RESULTS for stored precedures - to support INOUT vars ###
  @dbh = Mysql.real_connect("127.0.0.1", "phoebe", "", "geonames",3306,nil,Mysql::CLIENT_MULTI_RESULTS)
      puts "Server version: " + @dbh.get_server_info
    rescue Mysql::Error => e
      puts "Error code: #{e.errno}"
      puts "Error message: #{e.error}"
      puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
    ensure
      # disconnect from server
      #@dbh.close if @dbh
    end
  end

  def findClosestWeather( lat, lon, dist)
  query= "call geonames.locswithinRadiuswithConds('weatherInfo','1',"+ lat.to_s + ',' + lon.to_s + ','+ dist.to_s+');'
	no_more_results=false
    puts query
    @dbh.query_with_result=false
    @dbh.query(query);
    until no_more_results 
      begin
		  res= @dbh.use_result
		  puts " Results has #{ res.num_rows.to_s } rows "
      rescue Mysql::Error => e 
        no_more_results=true
      end 
	  if !no_more_results
		  res.each { |row|
            puts row.inspect
          }
        res.free
		@dbh.next_result
      end
    end
  end

  def findClosestCity( lat, lon, dist)
    query="call geonames.withinRadius(" + lat.to_s + ',' + lon.to_s + ','+ dist.to_s+');'
	no_more_results=false
    puts query
    @dbh.query_with_result=false
    @dbh.query(query);
    until no_more_results 
      begin
		  res= @dbh.use_result
		  puts " Results has #{ res.num_rows.to_s } rows "
      rescue Mysql::Error => e 
        no_more_results=true
      end 
	  if !no_more_results
		  res.each { |row|
            puts row.inspect
          }
        res.free
		@dbh.next_result
      end
    end
  end
end

tsp= TestSP.new()
tsp.findClosestCity( -70.9 , -8.66, 20)
tsp.findClosestCity( -70.9 , -7.66, 20)
tsp.findClosestWeather( 53.9 , -3.66, 300)
