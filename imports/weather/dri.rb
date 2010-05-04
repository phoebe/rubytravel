$:.unshift File.join( %w{ /lib } )
$:.unshift File.join(File.dirname(__FILE__), '..', 'imports')
require File.join(File.dirname(__FILE__), '../imports', 'scraper' )

class Weather < Scraper
	def initialize()
		@info={'country_code'=>'US','source'=>'DRI'}
		@options={'country_code'=>'US','source'=>'DRI'}
		@url='http://www.wrcc.dri.edu/'
		@country={}
		@sunnydays={}
		@snowdays={}
		@raindays={}
		@mintemp={}
		@maxtemp={}
		@mintemp={}
		@prec={}
		@stations={}
		super
	end

	def	ft_to_m(f)
		f.to_f * 0.3048 rescue 0
	end

	def d_to_r(d,m,dir)
		deg= d.to_i + m.to_i*Math::PI/180
		if dir =~ /s|w/i
			-deg
		else
			deg
		end
	end

	def f_to_c(f)
		f*9/5+32;
	end

	def in_to_mm(inc)
		inc * 25.4
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

	def parsePage(doc,info,options={})
		h=info.dup
		doc.css('body center font').each { |t|
			# RENO, NEVADA
			tt= cleanString(t.text)
			ll= tt.split(/,\s*/)
			h['name']=ll[0].strip
			h['city']=h['name']
			h['state']=ll[1].strip.downcase.capitalize!
			h['admin1_code']=USstates::abbrev(h['state'])
			puts h.inspect
			code = @importer.findCity(h,options)
			puts "After lookup: "+ h.inspect
			break;
		}
		doc.css('p font[size]').each { |t|
=begin
			if t.text =~ /LATITUDE: ([-\d.]+)ø ([\d.]+)' (N|S) LONGITUDE: ([-\d.]+)ø ([\d.]+)' (E|W) ELEVATION: FT.  GRND      ([-\d.]+) BARO/
				h['latitude']= lat=d_to_r($1,$2,$3);
				h['longitude']= lon=d_to_r($4,$5,$6);
				ele=$7.to_i * 0.3048;
			if t.text =~ /LATITUDE:\s*(\d+)\s*\S+\s+(\d+)\s*\S+\s+(N|S)\s+/
				h['latitude']= lat=d_to_r($1,$2,$3);
				puts "LAT OK #{$1} #{$2} #{$3}  #{h['latitude']}"
			end
			if t.text=~/LONGITUDE:\s+([-\d]+)\s*\S+\s+([\d.]+)\s*\S+\s+(E|W)\s+/
				h['longitude']= lon=d_to_r($1,$2,$3);
				puts "LONG OK #{$1} #{$2} #{$3} #{h['longitude']}"
			end
			if t.text=~/ELEVATION:\s+FT.\s+GRND\s+([-\d.]+)\s+BARO/i
				h['elevation']= ele=$10.to_i * 0.3048;
				puts "ELEV OK #{$1} "
			end
=end
			if t.text =~ /LATITUDE:\s*(\d+)\s*\S+\s+(\d+)\s*\S+\s+(N|S)\s*LONGITUDE:\s+([-\d]+)\s*\S+\s+([\d.]+)\s*\S+\s+(E|W)\s*ELEVATION:\s+FT.\s+GRND\s+([-\d.]+)\s+BARO/i
				puts "PP LATLNG= #{$1+'.'+$2+'.'+$3}, #{$4+'.'+$5+'.'+$6} at #{$7} "
				h['latitude']= lat=d_to_r($1,$2,$3);
				h['longitude']= lon=d_to_r($4,$5,$6);
				h['elevation']= ele=$7.to_i * 0.3048;
				puts "ParseP LATLNG= #{ h['latitude']  }, #{ h['longitude']} at #{ h['elevation'] } "
				break;
			end
		}
		indx=-1
		tables={}
		table=:none
		doc.css('tr td').each { |tl|
			if (indx==0)
				indx=indx+1;
				next;
			end
			if (indx > 0)
				dc = tl.search('.//br/preceding-sibling::text()|.//br/following-sibling::text()');
				if (table==:temp)
					#puts "avg_#{indx}_temp = #{dc[2].text.strip} - #{dc[1].text.strip},"
					begin
					h["avg_#{indx}_max_temp"]=f_to_c(Float(dc[1].text.strip))
					rescue; end
					begin
					h["avg_#{indx}_min_temp"]=f_to_c(Float(dc[2].text.strip))
					rescue; end
				elsif (table==:prec)
					begin
					h["avg_#{indx}_rainfall_mm"]= in_to_mm(Float(dc[1].text.strip))
					rescue
					end
				elsif (table==:wind)
					h["avg_#{indx}_wind_mph"]=dc[1].text.strip.to_f
				elsif (table==:sun)
					h["avg_#{indx}_sunnydays"]=dc[2].text.strip.to_f
					h["avg_#{indx}_snowdays"]=dc[5].text.strip.to_f
					h["avg_#{indx}_raindays"]=dc[6].text.strip.to_f
				end
			end
			indx=indx+1 if indx >= 0;
			indx = -1 if indx > 12;
			t= tl.text
			if t =~ /WIND/ 
				table=:wind
				indx=0;
				next;
			end
			if t =~ /PRECIPITATION/ 
				table=:prec
				indx=0;
				next;
			end
			if t =~ /TEMPERATURE/ 
				table=:temp
				indx=0;
				next;
			end
			if t =~ /MEAN SKY COVER/ 
				table=:sun
				indx=0;
				next;
			end
		}
		doc.search('.//br/following-sibling::text()').each { |p|
			t=p.text
			if t =~/Normals\s+-\s+Based on the \d{4} - (\d{4}) record period./
				#print " date = #{$1} ";
				h['lastdate']=$1.strip
			end
		}
		#puts h.inspect
		q= constructquery(h)
		puts q;
		@importer.insertIntoDB(q);
	end

	#http://www.wrcc.dri.edu/cgi-bin/cliMAIN.pl?az6616
	def parseLegacy(doc,info,options={})
		h=info.dup
		doc.css('h1').each { |t|
			puts t.inspect
			if t.text =~ /(\S[^,]+),([^(]+)\((\d+)\)/
			   h['name']=$1;
			   h['state']=$2.strip.downcase.capitalize!;
			   h['alternatenames']=$3.strip
			   h['admin1_code']=USstates::abbrev( h['state'])
			end
		}
		doc.css('a[href]').each { |a|
			h['info']=a[:href] if a.text =~/Station Metadata/ 
		}
		doc.css('h4').each { |t|
			#if t.text =~ /Period of Record\s*:\s*[\d\/]+\d{4}\s+to\s+(\d{1,2}\/\s*\d{1,2}\/\d{4})/im 
			if t.text =~ /\d{4}\s+to\s+(\d{1,2}\/\s*\d{1,2}\/\d{4})/im 
				h['lastdate']=$1.strip
			end
		}
		doc.css('tr').each { |tr|
			tds= tr.css('td')
			t=tds[0].text
			if (t =~ /Average Max. Temperature/)
				key= 'max_temp'
				conv= self.method(:f_to_c)
			elsif (t =~ /Average Min. Temperature/)
				key= 'min_temp'
				conv= self.method(:f_to_c)
			elsif (t =~ /Average Total Precipitation/)
				key= 'rainfall_mm'
				conv= self.method(:in_to_mm)
			else
				key='hold'
			end
		   (1..12).each { |m|
				begin
					h["avg_#{m}_#{key}"]= conv.call( Float(tds[m].text)) # only good numbers
				rescue
				end
			 }
		}
		unless findStation(h,options)
			unless h['info'].nil?
				puts "## Did not find station - look up "+h['info'];
				sleep rand(4)
				doc = urlHandle(@url+h['info'])
				parseStation( doc,h)
			end
		end
		if checkData(h)
			q= constructquery(h)
			puts q;
			@importer.insertIntoDB(q);
		else
			puts "Insufficent Record: "+h.inspect
		end
	end
	def checkData(h)
		return false if ( h['avg_1_min_temp'].nil? && h['avg_1_max_temp'].nil? && h['avg_1_rainfall_mm'].nil?)
		return false if ( h['latitude'].nil? || h['longitude'].nil? || h['source'].nil? )
		true
	end

	def constructquery(h)
		fstr='';
		vstr='';
		h.each { |k,v|
			if (k=~/avg_\d+_rainfall|avg_\d+_m.._temp|avg_\d+_snowdays|avg_\d+_raindays|avg_\d+_sunnydays/)
				fstr=fstr+k+',';
				vstr=vstr+v.to_s+',';
			end
		}
		%w(latitude longitude elevation geonameid).each { |l|
			next if h[l].nil?
			fstr= fstr+l+',';
			vstr=vstr+ h[l].to_s+',';
		}
		%w(source lastdate).each { |l|
			next if h[l].nil?
			fstr= fstr+l+',';
			vstr=vstr+ '"'+h[l]+'",';
		}
		fstr.chomp!(',')
		vstr.chomp!(',')
=begin
		fstr= fstr+'latitude,longitude,source,lastdate';
		vstr= vstr+h['latitude'].to_s+','+h['longitude'].to_s+',"'+h['source']+'","'+h['lastdate']+'"';
=end
		q='insert into weatherInfo ('+fstr+') values ('+vstr+')';
		return q;
	end

	def constructQueryWithList(h,stringlist,numlist)
		fstr='';
		vstr='';
		puts "constructQueryWithList : "+h.inspect
		stringlist.each { |l|
			next if h[l].nil?
			fstr= fstr+l+',';
			vstr=vstr+ '"'+h[l]+'",';
		}
		numlist.each { |l|
			next if h[l].nil?
			fstr= fstr+l+',';
			vstr=vstr+ h[l].to_s+',';
		}
		puts fstr;
		puts vstr;
		fstr.chomp!(',')
		vstr.chomp!(',')
		return '('+fstr+') values ('+vstr+')';
	end

	def toRad(ff)
		return d_to_r($1,$2,'') if ff=~ /([-\d]+)(\d{2})/
		return nil
	end

	def findStation(info,options={})
		puts info.inspect
		return nil if info['alternatenames'].nil?
		n=info['alternatenames']
		q="select latitude,longitude,elevation,name from stations where alternatenames = '#{ Mysql::escape_string(n) }'"
		puts q
		res= @importer.selectquery(q)
		found=false
		res.each { |ans|
			found=true
			info['latitude']=ans[0]
			info['longitude']=ans[1]
			info['elevation']=ans[2]
			info['name']=ans[3]
		}
		puts "Weather station #{n} known" if found
		return found
	end

	def parseStation(doc,info)
		doc.search('tr').each { |tr|
			fields=tr.search('td')
			if (fields.length == 14 && fields[3].text=~/\d+/)
				info['alternatenames']= $1 if fields[1].text=~/(\d{5,})/
				info['name']= fields[2].text.strip
				info['latitude']=toRad(fields[3].text)
				info['longitude']=toRad(fields[4].text)
				#### BUG ADJUSTMENT - their coordinates are missing a direction
				info['longitude']= -info['longitude'] if info['longitude']>0 && info['country_code']=='US' # all in the US
				info['elevation']=ft_to_m(fields[5].text.to_i/10.0)
				info['feature_class']='S';
				info['feature_code']='STNM';
				puts "LAT LON #{info.inspect} "
				h=info
				q = constructQueryWithList(h, %w(name alternatenames feature_code country_code  source  admin1_code), %w(longitude latitude elevation))
				q='insert into stations '+q;
=begin
				q='insert into stations (name,alternatenames,longitude,latitude,elevation,feature_code,country_code, source, admin1_code) values ("'+
				h['name']+'","'+h['alternatenames']+'",'+
				h['longitude'].to_s+','+h['latitude'].to_s+','+h['elevation'].to_s+
				',"STNM","'+h['country_code']+'","'+h["source"]+'","'+h['admin1_code']+'");'
=end
				puts q.inspect
				@importer.insertIntoDB(q);
			end
		}
	end

	def parseCLists(doc,info,options={})
		# look for /cgi-bin/clilcd.pl?pi40505
	   h=info.dup
	   doc.css('a[href]').each{ |a|
		   if a[:href] =~/clilcd.pl\?/
			   l= a[:href]
			   l=@url+l unless ( l=~/^http:\.\/\// );
			   puts " parsePage #{l}";
			   parseUrl(l,h);
			   sleep rand(4);
		   end
		}
	end

	def parseMLframe(l)
	   doc=urlHandle(l);
	   doc.css('frame[src]').each{ |a|
		   if (a[:name] =~ /graph/i)
			   l=a[:src];
			   l=@url+l unless ( l=~/^http:\.\/\// );
			   return l
		   end
	   }
	end

	def parseMLists(doc,info,options={})
	   # /summary\/Clims => http://www.wrcc.dri.edu/cgi-bin/cliMAIN.pl?ca1056
	   h=info.dup
	   as = doc.css('a[href]');
	   as.each{ |a|
		   if a[:href] =~/cliMAIN.pl\?/
			   l= a[:href]
			   l=@url+l unless ( l=~/^http:\.\/\// );
			   puts " parseLegacy #{l}";
			   l= parseMLframe(l)
			   puts " parseLegacy GOT #{l}";
			   doc=urlHandle(l);
			   parseLegacy(doc,h,options);
			   sleep rand(4);
		   end
	   }
	end

	def parseIndex(doc,info,options={})
		%w(listlcd.html listlcdak.html listlcdpi.html).each { |f|
			#ff= 'http://www.wrcc.dri.edu/summary/'+f
			# look for /cgi-bin/clilcd.pl?pi40505
		}
		links=[]
	   doc.css('a[href]').each{ |a|
			   # /summary\/Clims => http://www.wrcc.dri.edu/cgi-bin/cliMAIN.pl?ca1056
			   # /summary\/lcd/ => /cgi-bin/clilcd.pl?or24229
		   if a[:href] =~/\/summary\//
			links<< a[:href]
		   end
	   }
	   links.each { |l|
		   l=@url+l unless ( l=~/^http:\.\/\// );
		   puts l
		   if  ( l=~/\/summary\/Climsm(\w+)/ )
			    st=$1;
			    puts " parseLegacy #{l}";
				unless st =~ /ak/
					link="http://www.wrcc.dri.edu/summary/"+st+"lst.html"; #http://www.wrcc.dri.edu/summary/azlst.html
					doc=urlHandle(link);
					parseMLists(doc,info,options)
					sleep rand(4)
				end
		   elsif  ( l=~/\/summary\/lcd/ )
			   puts " parseSummary.pl #{l}";
=begin
			    doc=urlHandle(l);
				parseCLists(doc,info,options)
				sleep rand(4)
=end
		   end
	   }
	end

	def test
		# http://www.wrcc.dri.edu/cgi-bin/cliRECtM.pl?az9652
=begin
		parseDoc('reno_clim.html',@info);
		parseDoc('portland.html',@info)
		parseDoc('cheyenne.html',@info)
		parseDoc('juno.html',@info)
		parseDoc('yap.html',@info)
		doc=docHandle('yuma.html')
		parseLegacy(doc,@info);
		doc=docHandle('arapahoe.html')
		parseLegacy(doc,@info);
		l='http://www.wrcc.dri.edu/summary/listlcdpi.html'
		doc=urlHandle(l);
		parseCLists(doc,@info,@options)
		l='http://www.wrcc.dri.edu/summary/listlcdak.html'
		doc=urlHandle(l);
		parseCLists(doc,@info,@options)
		doc=docHandle('Climsum.html');
		parseIndex(doc,@info);

		doc=docHandle('ak0400.html');
		parseStation(doc,@info);
		doc=docHandle('badjuju.html')
		parseLegacy(doc,@info);
		#doc=urlHandle(@url);

		l='http://www.wrcc.dri.edu/summary/aklst.html';
		doc=urlHandle(l);
		parseMLists(doc,@info,@options)

		doc=docHandle('pipespring.html');
		parseStation(doc,@info);

=end
		doc=docHandle('Climsum.html');
		parseIndex(doc,@info);
	end
end


w= Weather.new
w.test

  
