
class USstates
	attr_reader :names

	def self.test
		puts "OK" if abbrev('California') == 'CA'
		puts "OK" if longname('MA') == 'Massachusetts'
	end

	def self.names
		return @names
	end

	def self.territories
		return @territory
	end

	def self.abbrev(st)
		@names.fetch(st.downcase.capitalize) rescue ""
	end

	def self.longname(abr)
		@names.index(abr.downcase.capitalize) rescue ""
	end


	@names = Hash[
		'Alabama'=>'AL',
		'Alaska'=>'AK',
		'Arizona'=>'AZ',
		'Arkansas'=>'AR',
		'California'=>'CA',
		'Colorado'=>'CO',
		'Connecticut'=>'CT',
		'Delaware'=>'DE',
		'Florida'=>'FL',
		'Georgia'=>'GA',
		'Hawaii'=>'HI',
		'Idaho'=>'ID',
		'Illinois'=>'IL',
		'Indiana'=>'IN',
		'Iowa'=>'IA',
		'Kansas'=>'KS',
		'Kentucky'=>'KY',
		'Louisiana'=>'LA',
		'Maine'=>'ME',
		'Maryland'=>'MD',
		'Massachusetts'=>'MA',
		'Michigan'=>'MI',
		'Minnesota'=>'MN',
		'Mississippi'=>'MS',
		'Missouri'=>'MO',
		'Montana'=>'MT',
		'Nebraska'=>'NE',
		'Nevada'=>'NV',
		'New Hampshire'=>'NH',
		'New Jersey'=>'NJ',
		'New Mexico'=>'NM',
		'New York'=>'NY',
		'North Carolina'=>'NC',
		'North Dakota'=>'ND',
		'Ohio'=>'OH',
		'Oklahoma'=>'OK',
		'Oregon'=>'OR',
		'Pennsylvania'=>'PA',
		'Rhode Island'=>'RI',
		'South Carolina'=>'SC',
		'South Dakota'=>'SD',
		'Tennessee'=>'TN',
		'Texas'=>'TX',
		'Utah'=>'UT',
		'Vermont'=>'VT',
		'Virginia'=>'VA',
		'Washington'=>'WA',
		'Washington dc'=>'DC',
		'West Virginia'=>'WV',
		'Wisconsin'=>'WI',
		'Wyoming'=>'WY'
	]

	@territory={
		'American Samoa'=>'AS',
		'District of Columbia'=>'DC',
		'Federated States of Micronesia'=>'FM',
		'Guam'=>'GU',
		'Marshall Islands'=>'MH',
		'Northern Mariana Islands'=>'MP',
		'Palau'=>'PW',
		'Puerto Rico'=>'PR',
		'Virgin Islands'=>'VI'};

end

# USstates::test
