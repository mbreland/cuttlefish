require File.expand_path('../app/search.rb', __FILE__)
require 'app/scrape'
require 'app/display'

desc "Clear out all files in ./tmp directory and destroy Gemfile.lock"
task :clean do
  generated_files = FileList['./tmp/*.html']
  if File.exists?("Gemfile.lock")
    gemfile_lock = File.open("Gemfile.lock").path
    generated_files.to_a << gemfile_lock
  end
  generated_files.each { |file| File.delete(file) }
end

speeds = {"all" => "full", "most" => "concise"}
types = {"gigs" => "ggg", "jobs" => "jjj", "housing" => "hhh", "for_sale" => "sss", "services" => "bbb", "community" => "ccc"}

desc "Cuttlefish will hold your hand."
task :cuttlefish do
  puts "}-(((*> Choose a category: \n#{types.keys.map { |x| x + " "}}"
  key = STDIN.gets.chomp
  puts "}-(((*> '#{key}'"
  while !types.key?(key) do
    puts "WRONG. DO IT AGAIN:"
    key = STDIN.gets.chomp
  end
  category = types.fetch(key)
  category_full = key
  puts "}-(((*> Query: "
  query = STDIN.gets.chomp
  puts "}-(((*> '#{query}'"
  search(category, "concise", query, category_full)
end

speeds.each do |key, speed|
  namespace key do
    types.each do |category_full, type_short|
      key == "all" ? (desc "Searches all cities in the #{category_full} category.") : (desc "Searches major cities in the #{category_full} category.")
      
      task category_full do
        puts "}-(((*> Query: "
        query = STDIN.gets.chomp
        puts "}-(((*> '#{query}'"
        search(type_short, speed, query, category_full)
      end
    end
  end
end

def search(type_short, speed, query, category_full)
  Search.new(type_short, query, 'cl', speed, category_full)
end