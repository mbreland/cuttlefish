#!/usr/bin/env ruby
require 'rubygems'
require 'simple_progressbar'
require 'open-uri'
require 'nokogiri'

#args = "#{ARGV[0]}, #{ARGV[1]}, #{ARGV[2]}, #{ARGV[3]}"
#if ARGV[2..3].nil?
#  args = "#{ARGV[0]}, #{ARGV[1]}, cl, concise"
#  Scrape.new(args)
#  puts "Searching for best possible matches at a success rate of ~90-95%.\nFor full listings, pass in 'full' as an argument.\n"
#  
#elsif ARGV[3] == "full" 
#    args = "#{ARGV[0]}, #{ARGV[1]}, cl, concise"
#    Scrape.new(args)
#    puts "This can take up to 5 minutes depending on your connection. Please be patient.\n"
#    
#elsif ARGV[0] == "-h" || ARGV[0] == "-H"
#  
#  puts "Valid arguments are:\n 'concise' 'full'"
#  Process.exit
#else
#  
#  puts "Invalid argument.\nYou must pass  Valid arguments are:\n 'concise' 'full'"
#  Process.exit
#end


class Search
  attr_accessor :doc
  def initialize(gig, search, site, speed)
    @doc = Nokogiri::HTML(open(get_base_url(site)))    
    city_links = get_city_links(speed)
    cities = city_links.map { |link| link.inner_text }
    formatted_links = links_with_search_params(city_links, gig, search)
    Scrape.new(formatted_links, gig, search)
  end

  def get_city_links(speed)
    speed == "full" ? @doc.xpath("//div/a").map { |link| link } : @doc.xpath("//div/a/b").map { |link| link.parent }
  end
  
  def links_with_search_params(city_links, gig, search)
    city_links.map { |link| link['href'] + "search/#{gig}?query=#{search}" }
  end

  private
  
  def get_base_url(site)
    #arrays of acceptable user input
    cl = ["Craigslist", "craigslist", "cl", "CL"]
    if cl.include?(site)
      @base_url = 'http://geo.craigslist.org/iso/us/'
    elsif site.nil?
      @base_url = 'http://geo.craigslist.org/iso/us/'
    else
      puts "Couldn't figure out which site you wanted.\nType -h to view optons."
      Process.exit
    end
  end
end

class Scrape

  def initialize(links, gig, search)
    raw_pages = scrape_cities(links)
    postings = get_postings(raw_pages)
    puts "found #{postings.count} postings"
    Display.new(postings, gig, search)
  end
  
  def scrape_cities(links)
    @@big_list_o_jobs = []
    @@links = links
    SimpleProgressbar.new.show("Grabbing page source from #{@@links.length} cities") do
      begin
        @@links.each_with_index do |doc, index| 
          @@big_list_o_jobs << Nokogiri::HTML(open(doc)).xpath("//html/body") 
          progress (((index + 1).to_f / @@links.length)*100).to_i
        end
      rescue RuntimeError => e
        log.warn "--RUNTIME ERROR--"
        log.error e
      end
    end
    @@big_list_o_jobs
  end
  
  def get_postings(raw_pages)
    threads = []
    raw_pages.each do |poop|
      search = poop.xpath("//blockquote/p")
      search.each do |link|
        unless link.nil? || threads.include?(link) || link.include?('!')
          location = link.at_css('font').nil? ? "( o_O )" : link.at_css('font').inner_text
          threads << [link.inner_text.scan(/(...\s.\d)/), link.at_css("a"), location]
        end
      end  
    end
    threads
  end
end

class Display 
  attr_accessor :out_file
  
  def initialize(postings, gig, search) 
    @out_file = Time.now.strftime("scraped #{gig} for #{search} at %I:%M %m:%d:%Y.html").gsub(' ', '_') 
    display_in_browser(postings, search)
  end
  def display_in_browser(postings, search)
    File.open(@out_file, "w+") do |file|
      file.puts "<!DOCTYPE html> 
<html lang='en'>
<head> 
	<meta charset=utf-8>
	<title>Craigslist Scraper</title>
	<meta name=author content='Tyler Breland'>  
	<link href='./style.css' media='screen' rel='stylesheet' type='text/css' /> 
	<script src='./jquery-1.5.1.min.js' type='text/javascript'></script>
</head>
<body>"
      postings.each do |link|
        number = link[0].to_s.scan(/\d+/)
        format_date = number.to_s.to_i < 10 ? link[0].to_s + "&nbsp;" : link[0]
        file.puts " #{format_date} - #{link[1]} - #{link[2]}</br></br>"
      end
      file.puts "</body></html>"
    end
    #open that shit! If you're on windows, fuck you. get a real os.
    system("open #{@out_file}")
  end
end
class Array
  def to_hash_keys(&block)
    Hash[*self.collect { |v|
      [v, block.call(v)]
    }.flatten]
  end

  def to_hash_values(&block)
    Hash[*self.collect { |v|
      [block.call(v), v]
    }.flatten]
  end
end

class City
  attr_accessor :name
  
  def initialize(name)
    @name = name
  end
end


Search.new('cpg','rails', 'cl', 'concise')
