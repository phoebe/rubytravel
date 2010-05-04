#!/usr/bin/env ruby
# encoding: utf-8   # meaningful for Ruby 1.9 only
begin
  # bring in utf-8 support (for Ruby 1.8 only)
  require 'jcode'  
  $KCODE = 'U'     
rescue LoadError   # no 'jcode' present or needed for Ruby 1.9
end

require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'stringex' # adds String#to_ascii method


class FacultyNames

  # The '@names' hash maps a full name to a 2-element array of [first_name, last_name]
  # e.g. "John Maynard Keynes" => ["John Maynard", "Keynes"]
  def initialize
    @names = Hash.new
  end
  
  def add(full, first, last)
    @names[full] = [first, last]
  end
  
  # Parse the faculty directory page at 'url', and add the names found there to the hash.
  def add_names_from_page(url)
    doc = Nokogiri.parse(open(url))
    headers = doc / '//h2[@class="facheader"]'  # find each <h2 class="facheader">..</h2> element
    headers.each do |h2|
      # the <h2 class='facheader'> element contains a single ASCII capital letter,
      # which is the initial letter of all last names of instructors 
      # that follow this <h2> element
      initial_letter = h2.text
      # Loop through all following siblings to the <h2> element,
      # until we reach something other than a text node or a <p>
      node = h2
      while (node = node.next)
        next if node.text?  # skip over (blank) text nodes
        break if (node.element? and node.name != 'p')  # stop at the first non-<p> element
        name = (node / './strong').text  # instructor name is within <p><strong>..</strong></p>
        first, last = split_name(name, initial_letter)
        @names[name] = [first, last]
      end
    end
  end
  
  # Look up the full name, return a 2-element array of [first_name, last_name]
  def lookup(name)
    result = @names[name]
    if (!result)
      # if a 'middle' name-word is a single letter not followed by a period,
      #   add a period and try again (e.g. "Harry S Truman" => "Harry S. Truman")
      result = @names[name.gsub(/ ([a-z]) /i, ' \1. ')]
    end
    result
  end
  
  # split an instructor's name into "first" and "last" components,
  # where the "last" name must begin with the given initial letter 
  # (Initial letter is specified as an ASCII capital, but the last name may actually begin
  #  with a lowercase or accented form of that letter)
  # e.g. split_name("Mario Vargas Llosa", "V") returns ["Mario", "Vargas Llosa"}
  private
  def split_name(name, initial_letter)
    words = name.split
    words.each_with_index do |word, ix|
      next if ix == 0  # first name must have at least one word
      next if word[-1,1] == '.' # first word of last name can't be an initial (e.g. "S." )
      if (word.each_char.first.to_ascii.upcase == initial_letter)
        # NOTE: for Ruby 1.8 utf-8 compatibilty this must NOT be: word[0,1].upcase.deaccent
        # first letter of this word matches initial letter,
        # so we'll assume that this word begins the last name
        first = words[0...ix].join(' ')
        last = words[ix..-1].join(' ')
        return first, last
      end
    end
    raise "split_name failure: #{name}"
  end

end

class SectionInfo 
  
  # parse a table row, read all the relevant course & section data from it
  def initialize(row)
    tds = row / './td'
    @term = tds[0].text.strip
    @dept = (tds[2] / "./text()[1]").text.strip.upcase
    full_number = (tds[2] / "./text()[2]").text.strip
    full_number =~ /^(?:E-)?([0-9]+)([A-Z]?)(\/W)?$/i
    @number = $1
    @suffix = $2.downcase   # empty string if no suffix present
    @writing = $3   # nil if full_number doesn't end with "/W"
    @section = tds[3].text.strip
    @section = 1 unless @section =~ /[0-9]+/
    @title = (tds[4] / "./a").text.strip
    @instructors = (tds[4] / "./text()").collect {|s| s.text.strip.squeeze(' ')}.reject {|s| s.empty?}
    @canceled = (@instructors[0] =~ /Canceled/)
    @link = (tds[4] / "./a/@href").text
  end
  
  def fetch_course_description
    page = Nokogiri.parse(open(@link))
    @description = (page / '//blockquote[@class="coursedesc"]/p').text
    @writing = ((page / '//h4[@class="coursetitle"]/span[@class="cn"]').text) =~ /\/W/
  end
  
  # add all the info about this course & section to the database
  def add_to_database(faculty_names)
    return if @canceled  # don't add canceled courses to the database
    term = if (@term == "Fall")
             Term.find_by_session_and_year(Term::Fall, 2009)
           elsif (@term =~ /^January/)
             Term.find_by_session_and_year(Term::January, 2010)
           elsif (@term == "Spring")
             Term.find_by_session_and_year(Term::Spring, 2010)
           else
             raise "Invalid term: #{@term}"
           end
    department = Department.find_by_abbrev(@dept)
    course = department.courses.find_or_create_by_number_and_suffix(@number, @suffix)
    if (course.description.nil?)
      puts "Fetching #{course.full_number}"
      fetch_course_description
      course.description = @description
    end
    course.writing = (not @writing.nil?)
    course.title = @title
    course.save!
    section = course.sections.build do |s|
      s.number = @section
      s.term = term
    end
    begin
      section.save!
    rescue ActiveRecord::RecordInvalid => err
      # this can happen if sections are not properly numbered in the data we are reading
      puts err
      section.number += 1
      puts "retrying save for #{section.course.full_number}, #{term.name} - section number changed to #{section.number}"
      section.save!
    end
    @instructors.each do |ins|
      first, last = faculty_names.lookup(ins)
      if first.nil?
        puts "Warning - Instructor '#{ins}' not found in faculty name list"
        first, last = ins.split(' ', 2)
        faculty_names.add(ins, first, last)
      end
      section.instructors << Instructor.find_or_create_by_name(first, last)
    end
  end
    
end


class AddRealData

  def self.execute

    require 'db/migrate/20091215235455_add_comments.rb'
    require 'db/migrate/20091208203931_add_courses_data.rb'
    
    AddComments.down  # deletes all comments
    AddCoursesData.down  # deletes all instructors, sections, and courses
  
    faculty_names = FacultyNames.new
    ['a_c', 'd_f', 'g_i', 'j_l', 'm_o', 'p_r', 's_u', 'v_x', 'y_z'].each do |s|
      faculty_names.add_names_from_page("http://www.extension.harvard.edu/2009-10/about/faculty/#{s}.jsp")
    end

    p = WWW::Mechanize.new.get('http://dceweb.harvard.edu/prod/sswckce.taf?wgrp=EXT')
    if f = p.forms[1]
      # check off ALL of 'undergrad credit', 'graduate credit', 'non-credit'
      f.checkboxes_with(:name => 'credLevel').each {|b| b.check}
      results = f.submit
      (results / 'tr').each do |row|
        unless (row / "./td[@class='title']").empty?
          sec_info = SectionInfo.new(row)
          sec_info.add_to_database(faculty_names)
        end
      end
    end
    
    AddComments.up  # put sample comments back

  end

end
  


