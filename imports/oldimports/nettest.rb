require 'net/http'
require 'uri'

def fetch(urlStr)
  begin
  url = URI.parse( urlStr )
  puts  "url path="+url.path.inspect
  url.path='/' if url.path.empty?
  nethttp = Net::HTTP.new( url.host, url.port )
  nethttp.read_timeout = 1
  nethttp.open_timeout = 1
  res = nethttp.start() {|http|
    http.head(url.path)
  }
  puts  (res.kind_of? Net::HTTPResponse)
  puts "CODE "+res.code
  case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      puts "OK!!! "
      return true;
    else
      return false;
    end
  rescue Timeout::Error    # regular rescue only deals with stderr
    puts "UrlAvailable: Timeout 404 - #{urlStr}"
    return false; #assume the worse
  rescue URI::InvalidURIError => e
    puts "UrlAvailable: InvalidURIError #{e.inspect}  - #{urlStr}"
    return false; #assume the worse
  rescue SystemCallError
    puts "UrlAvailable:System Error - #{urlStr}"
    return false; #assume the worse
  #rescue OpenURI::HTTPError
    #puts "UrlAvailable:Cannot open [#{url}]"
    #return false; #assume the worse
  rescue Exception => e
    puts "UrlAvailable:Error open [#{url}]"
    return false; #assume the worse
  end
end

def fetch1(urlStr)
url = URI.parse( urlStr )
  puts  "url="+url.inspect
req = Net::HTTP::Get.new(url.path)
res = Net::HTTP.start(url.host, url.port) {|http|
  http.read_timeout = 1
  http.open_timeout = 5
http.request(req)
}
puts res.body
end

def fetch2(urlStr)
#begin
  url = URI.parse(urlStr)
  puts  "url="+url.inspect
  http = Net::HTTP.new( url.host, url.port )
  http.read_timeout = 1
  http.open_timeout = 5
  resp = http.start() {|http|
    http.request(url)
    puts  "HTTP="+http.inspect
  }
  puts ">> RESP="+resp.inspect
  puts  (resp.kind_of? Net::HTTPResponse)
  puts "CODE "+resp.code
  puts "BODY "+ resp.body
=begin
  case resp
    when Net::HTTPSuccess, Net::HTTPRedirection
      puts "OK!!! "
      return true;
    else
      return false;
    end
  rescue URI::InvalidURIError => e
    puts "UrlAvailable: InvalidURIError #{e.inspect}  - #{urlStr}"
  rescue Timeout::Error    # regular rescue only deals with stderr
    puts "UrlAvailable: Timeout 404 - #{urlStr}"
    return false; #assume the worse
  rescue SystemCallError
    puts "UrlAvailable:System Error - #{urlStr}"
    return false; #assume the worse
  #rescue OpenURI::HTTPError
    #puts "UrlAvailable:Cannot open [#{url}]"
    #return false; #assume the worse
  rescue Exception => e
    puts "UrlAvailable:Error open [#{url}]"
    return false; #assume the worse
  end
=end
end

%w( http://www.amwellvalleyvineyard.com/  http://www.plumcreekwinery.com/ http://www.chiff.com/wine/winery.htm  http://www.google.com http://www.domain.com one.dom ).each { |url|

  puts fetch(url)
}
