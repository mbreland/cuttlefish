require 'rubygems'
require 'simple_progressbar'
require 'open-uri'
require 'nokogiri'
require 'erb'

class Search
  attr_accessor :doc
  
  def initialize(gig, search, site, speed, type)
    @doc = Nokogiri::HTML(open(get_base_url(site)))   
    $type = type
    $gig = gig 
    $search = search
    
    links_array = make_state_array(speed)
    
    #city_links = get_city_links(speed)
    #grab a pretty list of cities using Nokogiri
    #cities = city_links.map { |link| link.inner_text }
    #grab a list of links with search params included
    #formatted_links = links_with_search_params(city_links, gig)
    #start scraping
    Scrape.new(links_array)
  end
  
  def make_state_array(speed)
    @@states = %w{AL AK AZ	AR CA CO CT DE FL GA HI ID IL IN IA KS KY LA ME MD MA MI MN MS MO MT NE NV NH NJ NM NY NC ND OH OK OR PA RI SC SD TN TX UT VT VA WA WV WI WY}
    #@@states = %w{IL MO}
    @@threads = []
    @@cities_with_dupes = []
    @@base_url = @base_url
    if speed == "full"
      SimpleProgressbar.new.show("Grabbing links of cities from geo.craigslist.org") do 
        @@states.each_with_index do |state, index|
          @@threads << Thread.new(state) { |url|
            scrape_url = @@base_url + url.downcase
            doc = Nokogiri::HTML(open(scrape_url))
            doc.css("#list a").each do |link|
              city_link = "<a href='#{link['href']}'>#{link.text}</a>"
              @@cities_with_dupes << [link['href'], state, link.text]
            end
          }
          progress (((index + 1).to_f / @@states.length)*100).to_i
        end
      end
    else
      SimpleProgressbar.new.show("Grabbing links of cities from geo.craigslist.org") do
        @@states.each_with_index do |state, index|
          @@threads << Thread.new(state) { |url|
            scrape_url = @@base_url + state.downcase
            doc = Nokogiri::HTML(open(scrape_url))
            doc.css("#list a b").each do |link|
              city_link = link.parent
              @@cities_with_dupes << [city_link['href'], state, city_link.text]
            end
          }
          progress (((index + 1).to_f / @@states.length)*100).to_i
        end
      end
    end
    @@threads.each { |t| t.join }
    links = remove_dupes(@@cities_with_dupes)
    format_array_links(links)
  end
  
  def remove_dupes(array)
    test_array = array.map {|x| x[0] }
    unique_cities = []
    new_array = []
    array.each do |city|
      unique_cities << city if test_array.count(city[0]) < 1 || !unique_cities.flatten.include?(city[0]) 
    end
    unique_cities.each do |p|
      link = "<a href='#{p[0]}'>#{p[2]}</a>"
      new_array << [link, p[1], p[0]]
    end
    new_array
  end
  
  def get_city_links(speed)
    speed == "full" ? @doc.xpath("//div/a").map { |link| link } : @doc.xpath("//div/a/b").map { |link| link.parent }
  end
  
  def links_with_search_params(city_links)
    city_links.map { |link| link['href'] + "search/#{$gig}?query=#{$search}" }
  end
  
  def format_array_links(links)
    formatted = []
    links.each do |array|
      m = array[2] + "search/#{$gig}?query=#{$search}" 
      array[2] = m
      formatted << array
    end
    formatted
  end
  
  
  #IMPORTANT!
  #MOVE THIS METHOD INTO THE INITIALIZER
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