require "rubygems"
require "nokogiri"

file='./silverado.hack'
file='yp-Williams-Selyem-Winery.htm'
file='./yp-silverado-winery.htm'
file='./Chester-Hill-Winery-Inc.htm'
transformfile='./xhtml2vcard.xsl';
transformfile='./yp.xsl';

#//doc = Nokogiri.parse(File.open('./yp-silverado-winery.htm'));
doc   = Nokogiri::XML(File.read(file))
xslt  = Nokogiri::XSLT(File.read(transformfile))

puts xslt.transform(doc)
