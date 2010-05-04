
@weekdays=Array["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday",
                "Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]

def daycomp( d1, d2 )
  if (d1[0]==d2[0] && d1[1] == d2[1]) then return true; else return false; end
end

def packhours( list, hours )
  if ( hours.nil? || hours.empty? ) then return false; end 
    #hours=hours[0];
  list['hour_start']=hours['hour_start'].to_s
  list['hour_end']=hours['hour_end'].to_s
  #weekdays= [0,0,0,0,0,0,0];
  week= 'CCCCCCC';
    (0..6).each { |d| 
      if (@weekdays[d]== hours['weekday_start'] )
        d.upto(d+7) { |w| 
          #weekdays[ w.modulo(7) ]=1;
          week[ w.modulo(7) ]='O';
          #printf " #{ weekdays[w.modulo(7)]} W= #{w} week= (#{weekdays.inspect })"
          if (@weekdays[w]== hours['weekday_end'] ) then break; end
        }
        break;
      end
    }
    #puts weekdays.inspect;
    puts week.inspect;
  list['open_days']=week;
  puts daycomp( "Tueday", "Tues" )
  puts daycomp( "Tteday", "Tues" )
  return true;
end


list=Hash.new;
hours=Hash.new;
hours['weekday_start']='Wednesday';
hours['weekday_end']='Friday';
hours['hour_start']='8:00';
hours['hour_end']='5:00';

packhours( list, hours );

