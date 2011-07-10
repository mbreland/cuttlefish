require File.expand_path('../app/search.rb', __FILE__)
require 'app/scrape'
require 'app/display'

desc "Clear out all files in ./tmp directory and destroy Gemfile.lock"
task :clean do
  generated_files = FileList['./tmp/*.html']
  gemfile_lock = File.open("Gemfile.lock").path
  generated_files.to_a << gemfile_lock
  generated_files.each { |file| File.delete(file) }
  
end

speeds = {"all" => "full", "most" => "concise"}
types = {"gigs" => "ggg", "jobs" => "jjj", "housing" => "hhh", "for_sale" => "sss", "services" => "bbb", "community" => "ccc"}

desc "Cuttlefish will hold your hand."
task :cuttlefish do
  puts "Choose a category: \n#{types.keys.map { |x| x + " "}}"
  key = STDIN.gets.chomp
  while !types.key?(key) do
    puts "WRONG. DO IT AGAIN:"
    key = STDIN.gets.chomp
  end
  category = types.fetch(key)
  puts "Query: "
  query = STDIN.gets.chomp
  search(category, "concise", query)
end

speeds.each do |key, speed|
  namespace key do
    types.each do |type, type_short|
      key == "all" ? (desc "Searches all cities in the #{type} category.") : (desc "Searches major cities in the #{type} category.")
      
      task type do
        puts "Query: "
        query = STDIN.gets.chomp
        search(type_short, speed, query)
      end
    end
  end
end

def search(type, speed, query)
  Search.new(type, query, 'cl', speed)
end