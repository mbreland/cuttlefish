#!/usr/bin/env ruby
require 'rubygems'
require 'simple_progressbar'
require 'open-uri'
require 'nokogiri'

load 'scrape.rb'
load 'display.rb'

class Search
  attr_accessor :doc
  
  def initialize(gig, search, site, speed)
    @doc = Nokogiri::HTML(open(get_base_url(site)))    
    city_links = get_city_links(speed)
    #grab a pretty list of cities using Nokogiri
    cities = city_links.map { |link| link.inner_text }
    #grab a list of links with search params included
    formatted_links = links_with_search_params(city_links, gig, search)
    #start scraping
    Scrape.new(formatted_links, gig, search)
  end

  def get_city_links(speed)
    speed == "full" ? @doc.xpath("//div/a").map { |link| link } : @doc.xpath("//div/a/b").map { |link| link.parent }
  end
  
  def links_with_search_params(city_links, gig, search)
    city_links.map { |link| link['href'] + "search/#{gig}?query=#{search}" }
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

Search.new('cpg','rails', 'cl', 'full')
