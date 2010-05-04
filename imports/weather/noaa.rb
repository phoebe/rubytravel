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
			fields= line.split(/,/)
			if fields.size ==17 and isNumeric(fields[0])
				k=fields[1].strip
				y=fields[2].strip
				m=fields[3].strip.to_i
				@stations[k]=fields[0].strip
				printme = ( @stations[k] == "87155")
				puts "#{k} #{m}/#{y} maxtemp=#{fields[8] } mintemp=#{fields[10] } prec=#{ fields[16]}" if printme
				@mintemp[k]={} if ( @mintemp[k].nil? ) 
				@maxtemp[k]={} if ( @maxtemp[k].nil? ) 
				@prec[k]={} if ( @prec[k].nil? ) 
				@mintemp[k][m]={} if ( @mintemp[k][m].nil? ) 
				@maxtemp[k][m]={} if ( @maxtemp[k][m].nil? ) 
				@prec[k][m]={} if ( @prec[k][m].nil? ) 

				@maxtemp[k][m][y] = Float( fields[8])rescue -9999
				@mintemp[k][m][y] = Float(fields[10]) rescue -9999
				@prec[k][m][y] = Float(fields[16]) rescue -9999
				i=i+1
			end
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
			#puts  "MAX #{@stations[k]} #{k}/#{y}= #{ @maxtemp[k][y]['average'] }"
		  }
		  #y=t[0]
		  #puts  "MAX #{k}/#{y}= #{ @maxtemp[k][y]['average'] }"
		}
		@prec.each { |k,t|
		  printme=( @stations[k]=='87155');
		  puts "PREC #{k}:"	if printme
		  t.each { |y,v|
			t=0; ff=0.0
			  print "#{y}:"  if printme
			v.each { |i,j| # print "(#{i}: #{j})"
				unless ( j < -900 )
					ff= ff+j
					t= t+1
				end
			}
			if (t > 1)
				a=ff/t
				@prec[k][y]['total'] = ff 		# if is only good if I have the whole year!
				@prec[k][y]['average'] = a 
				puts  "= #{ff}/#{t}= #{a}" if printme
			end
		  }
		}
		@stations.each { |k,n|
		printme=( n=='87155');
		fstr="insert into weatherInfo (";
		pvstr=") values (";
		vstr=""
		  if printme
			  puts "BAD PREC ="+k+" "+n if @prec[k].nil?
		  end
		  (1..12).each { |m|
		  if printme
			  puts "BAD MON ="+k+" "+m if @prec[k][m].nil?
		  end
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
		  lstr=""
	     #q="select latitude,longitude from stations where name='#{ Mysql::escape_string(k) }'"
	     q="select latitude,longitude from stations where alternatenames = '#{ Mysql::escape_string(n) }'"
		 puts q
		 res= @importer.selectquery(q)
		 res.each { |ans| 
			 lstr =ans[0].to_s+ ","+ ans[1].to_s
		 }

		  unless vstr.blank?
			  if lstr.blank? 
				  puts "MISSING #{k}: ";
				  fstr=fstr+'source' 
				  vstr=vstr+'NOA'
				  print fstr; print pvstr;
				  print vstr;
				  puts ')';
			  else
			  puts " #{k}: ";
			  q= fstr+'latitude,longitude,source'+ pvstr + vstr+lstr+',"NOA")'
			  print q;
			 @importer.insertIntoDB(q);
			  end
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
		  if  (line=~/^\d+/ )
			h['alternatenames']=n= line[0,9].strip
			h['name']= line[10,30].strip
			lng=line[45,5].strip
			lat=line[51,5].strip
			h['elevation']=line[58,5].strip
			h['country']= line[65,30].strip
			h['region'] = line[92,50].strip
			if (lat=~/-?\d+\.\d+/)
				h['latitude']=lat
			elsif (lat=~/(-?\d{1,3})(\d{2})/)
				h['latitude']=$1.to_s + ($2.to_f/60).to_s.slice(1,7) # has decimal pt
			end
			if (lng=~/-?\d+\.\d+/)
				h['longitude']=lng
			elsif (lng=~/(-?\d{1,3})(\d{2})/)
				h['longitude']=$1.to_s + ($2.to_f/60).to_s.slice(1,7) # has decimal pt
			end
			#puts h.inspect + " lng= "+lng+", lat="+lat
			i=i+1
			if ( lng=="0" || lng =~ /999/)
				#puts "JUNK"
				next;
			end
			 q="select latitude,longitude from stations where alternatenames = '#{ Mysql::escape_string(n) }'"
			 res= @importer.selectquery(q)
			 found=false
			 res.each { |ans| found=true }
			 puts "Weather station #{n} known" if found
			 next if found
=begin
=end
			if @country[ h['country'] ].nil?		# already looked up
				h['country_code']= @importer.findCountry( h['country'])
				@country[ h['country']]= h['country_code']
			else
				h['country_code'] = @country[ h['country']]
			end
			h['country_code']='' if h['country_code'].nil?
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
			#if ((line=~/(\d+)\s{2,}(\S.*\S)\s{8,}(\S.*\S)\s{8,}(-?\d{1,3})(\d{2})\s+(-?\d{1,3})(\d{2})\s+(\d+)/) ||(line=~/(\d+)\s{2,}(\S.*\S)\s{8,}(\S.*\S)\s{6,}(-?\d{1,3})(\d{2})\s+(-?\d{1,3})(\d{2})\s+(-?\d+)/ )|| (line=~/(\d+)\s{2,}(\S.*\S)\s{8,}(\S.*\S)\s{6,}\S.*\S\s{8,}\S+\s{8,}\d+\s{2,}(-?\d{1,3})(\d{2})\s+(-?\d{1,3})(\d{2})\s+(-?\d+)/ ))
		if (line=~/^\d+/)	
			h['alternatenames']= n = line[0,6].strip
			h['name']= line[7,30].strip
			h['country']= line[32,30].strip
			h['state'] = line[62,50].strip
			h['city']= line[115,30].strip
			lat=line[154,9].strip
			lng=line[163,9].strip
			h['elevation']=line[173,9].strip.to_f
			cd=line[145,9].strip
			if (lat=~/-?\d+\.\d+/)
				h['latitude']=lat
			elsif (lat=~/(-?\d{1,3})(\d{2})/)
				h['latitude']=$1.to_s + ($2.to_f/60).to_s.slice(1,7) # has decimal pt
			end
			if (lng=~/-?\d+\.\d+/)
				h['longitude']=lng
			elsif (lng=~/(-?\d{1,3})(\d{2})/)
				h['longitude']=$1.to_s + ($2.to_f/60).to_s.slice(1,7) # has decimal pt
			end
			i=i+1
			#puts "k= #{h['alternatenames']}, n=#{h['name']}, c=#{h['country']},s=#{h['state']},c=#{h['city']},el=#{h['elevation']}, lat=#{h['latitude']}, lng=#{h['longitude']}"
=begin
				h['alternatenames']=$1
				h['name']=$2
				h['country']=$3.to_s
				h['longitude']=$4.to_s + ($5.to_f/60).to_s.slice(1,7) # without the dot,70->7
				h['latitude']=$6.to_s + ($7.to_f/60).to_s.slice(1,7)
				h['elevation']=$8.to_f
=end
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


  
