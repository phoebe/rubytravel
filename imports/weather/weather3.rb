$:.unshift File.join( %w{ /lib } )
$:.unshift File.join(File.dirname(__FILE__), '..', 'imports')
require File.join(File.dirname(__FILE__), '../imports', 'scraper' )

class Weather < Scraper
	def initialize()
		@country={}
		@maxtemp={}
		@mintemp={}
		@prec={}
		@stations={}
		super
	end

	def assign(h,f)
		return if f.nil?
		begin
		   ff= Float(f)
		   return if ff < -999	
		   h=ff;
		rescue
		end
	end
	def tally(file)
		doc = File.open(file)
		i=0
		begin
		while ( line = doc.readline()) 
			if (line=~/(\d+),\s*([^,]+)\s+,(\d+),(\d+),\s*[-.\d]*,91,\s*([-.\d]*),92,\s*([-.\d]*),93,\s*([-.\d]*),94,\s*[-.\d]*,95,\s*[-.\d]*,96,\s*([-.\d]*)/)
				k=$2.strip
				y=$3.strip
				m=$4.strip
				@stations[k]=$1.strip
				#puts " #{mon}/#{y} #{k} #{$5} maxtemp=#{ $6} mintemp=#{ $7} prec=#{ $8}"
				@mintemp[k]={} if ( @mintemp[k].nil? ) 
				@maxtemp[k]={} if ( @maxtemp[k].nil? ) 
				@prec[k]={} if ( @prec[k].nil? ) 
				@mintemp[k][m]={} if ( @mintemp[k][m].nil? ) 
				@maxtemp[k][m]={} if ( @maxtemp[k][m].nil? ) 
				@prec[k][m]={} if ( @prec[k][m].nil? ) 

				@maxtemp[k][m][y] = Float($6)rescue -9999
				@mintemp[k][m][y] = Float($7) rescue -9999
				@prec[k][m][y] = Float($8) rescue -9999
				i=i+1
			end
			#return if i > 800
		end
		rescue EOFError
			doc.close
		end
		@mintemp.each { |k,t|		# station
		#puts "MIN #{k}:" 
		  t.each { |y,v|			# month
		  #print "#{y}:" 
			t=0; ff=0.0
			v.each { |i,j| # print "(#{i}: #{j})"		# year
				unless ( j < -900 )
					ff= ff+j
					t= t+1
				end
			}
			if t>1
				a=ff/t
				#puts  "= #{ff}/#{t}= #{a}"
				@mintemp[k][y]['average'] = a 
			end
		  }
		  y=t[0]
		  #puts  "MIN #{k}/#{y}= #{ @mintemp[k][y]['average'] }"
		}
		@maxtemp.each { |k,t|
		  #puts "MAX #{k}:" 
		  t.each { |y,v|
		  #print "#{y}:" 
			t=0; ff=0.0
			v.each { |i,j| # print "(#{i}: #{j})"
				unless ( j < -900 )
					ff= ff+j
					t= t+1
				end
			}
			if t>1 
				a=ff/t
				@maxtemp[k][y]['average'] = a 
			end
			#puts  "= #{ff}/#{t}= #{a}"
			puts  "MAX #{@stations[k]} #{k}/#{y}= #{ @maxtemp[k][y]['average'] }"
		  }
		  #y=t[0]
		  #puts  "MAX #{k}/#{y}= #{ @maxtemp[k][y]['average'] }"
		}
		@prec.each { |k,t|
		  #puts "PREC #{k}:" 
		  t.each { |y,v|
			t=0; ff=0.0
			  #print "#{y}:" 
			v.each { |i,j| # print "(#{i}: #{j})"
				unless ( j < -900 )
					ff= ff+j
					t= t+1
				end
			}
			if t>1 
			a=ff/t
			@prec[k][y]['average'] = a 
			end
			#puts  "= #{ff}/#{t}= #{a}"
		  }
		}
		@stations.each { |k,n|
		fstr="insert into weatherInfo (";
		pvstr=") values (";
		vstr=""
		  (1..12).each { |ms|
			  m=ms.to_s
			  #puts " #{ n} #{ k} => #{ m}"
			unless @prec[k].nil? ||  @prec[k][m].nil? || @prec[k][m]['average'].nil?
				fstr=fstr+'avg_'+m.to_s+'_rainfall_mm,'
				vstr=vstr+@prec[k][m]['average'].to_s+','
			end
			unless @maxtemp[k].nil? ||  @maxtemp[k][m].nil? || @maxtemp[k][m]['average'].nil?
				fstr=fstr+'avg_'+m.to_s+'_max_temp,'
				vstr=vstr+@maxtemp[k][m]['average'].to_s+','
			end
			unless @mintemp[k].nil? ||  @mintemp[k][m].nil? || @mintemp[k][m]['average'].nil?
				fstr=fstr+'avg_'+m.to_s+'_min_temp,'
				vstr=vstr+@mintemp[k][m]['average'].to_s+','
			end
		  }
		  unless vstr.blank?;
			  puts " #{k}: ";
			  fstr=fstr+ 'id' 
			  vstr=vstr+'"'+n+'"'
			  print fstr; print pvstr;
			  print vstr;
			  puts ')';

		  end

		}

	end

	def	addStation1(file)
		h={}
		country={}
		i=0;
	begin
		doc = File.open(file)
		while ( line = doc.readline()) 
			if  ((line=~/(\d+)\s{4,}(\S.*\S)\s{8,} (-?\d?\d)(\d{2})\s+(-?\d?\d)(\d{2})\s+(-?\d+)\s+(\S.\S+)\s{8,}(\w.*\w+)\s+\d+\s+\d+/)||(line=~/(\d+)\s{4,}(\S.*\S)\s{8,} (-?\d?\d)(\d{2})\s+(-?\d?\d)(\d{2})\s+(-?\d+)\s+(\S.\S+)\s{8,}(\w.+\w+)/ ))
				h['name']=$2
				h['alternatenames']=$1
				h['longitude']=$3.to_s + ($4.to_f/60).to_s.slice(1,7) # without the dot,70->7
				h['latitude']=$5.to_s + ($6.to_f/60).to_s.slice(1,7)
				h['elevation']=$7.to_f
				h['country']=$8.to_s
				h['region']=$9.to_s
				i=i+1
				if @country[ h['country'] ].nil?		# already looked up
					h['country_code']= @importer.findCountry( h['country'])
					@country[ h['country']]= h['country_code']
				else
					h['country_code'] = @country[ h['country']]
				end
				q=' insert into stations (name,alternatenames,longitude,latitude,elevation,feature_code,country_code, source) values ("'+
					h['name']+'","'+h['alternatenames']+'",'+
				h['longitude'].to_s+','+h['latitude'].to_s+','+h['elevation'].to_s+
				',"STNM","'+h['country_code']+'","NOA");'
				puts q.inspect
				@importer.insertIntoDB(q);
			end
			#return if i > 5;
			end
		rescue EOFError
			doc.close
		end
	end

	def	addStation2(file)
		h={}
		i=0;
	begin
		doc = File.open(file)
		while ( line = doc.readline()) 
			if  ((line=~/(\d+)\s{2,}(\S.*\S)\s{8,}(\S.*\S)\s{6,}(-?\d?\d)(\d{2})\s+(-?\d?\d)(\d{2})\s+(-?\d+)/ )|| (line=~/(\d+)\s{2,}(\S.*\S)\s{8,}(\S.*\S)\s{6,}\S.*\S\s{8,}\S+\s{8,}\d+\s{2,}(-?\d?\d)(\d{2})\s+(-?\d?\d)(\d{2})\s+(-?\d+)/ ))
				i=i+1
				h['alternatenames']=$1
				h['name']=$2
				h['country']=$3.to_s
				h['longitude']=$4.to_s + ($5.to_f/60).to_s.slice(1,7) # without the dot,70->7
				h['latitude']=$6.to_s + ($7.to_f/60).to_s.slice(1,7)
				h['elevation']=$8.to_f
				if @country[ h['country'] ].nil?		# already looked up
					h['country_code']= @importer.findCountry( h['country'])
					h['country_code']='' if h['country_code'].nil?
					@country[ h['country']]= h['country_code']
				else
					h['country_code'] = @country[ h['country']]
				end
				q='insert into stations (name,alternatenames,longitude,latitude,elevation,feature_code,country_code, source) values ("'+
					h['name']+'","'+h['alternatenames']+'",'+
				h['longitude'].to_s+','+h['latitude'].to_s+','+h['elevation'].to_s+
				',"STNM","'+h['country_code']+'","NOA");'
				puts q.inspect
				@importer.insertIntoDB(q);
			end
			#return if i > 5;
		end
	rescue EOFError
		doc.close
	end
	end


end


w= Weather.new
#w.addStation2('3859014213733stn.txt');
#w.addStation1('weather_stations.txt');
w.tally('3859014213733dat.txt');


  
