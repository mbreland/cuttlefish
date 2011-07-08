###############
# INITIALIZER #
###############

args = "#{ARGV[0]}, #{ARGV[1]}, #{ARGV[2]}, #{ARGV[3]}"
if ARGV[2..3].nil?
  args = "#{ARGV[0]}, #{ARGV[1]}, cl, concise"
  Scrape.new(args)
  puts "Searching for best possible matches at a success rate of ~90-95%.\nFor full listings, pass in 'full' as an argument.\n"
  
elsif ARGV[3] == "full" 
    args = "#{ARGV[0]}, #{ARGV[1]}, cl, concise"
    Scrape.new(args)
    puts "This can take up to 5 minutes depending on your connection. Please be patient.\n"
    
elsif ARGV[0] == "-h" || ARGV[0] == "-H"
  
  puts "Valid arguments are:\n 'concise' 'full'"
  Process.exit
else
  
  puts "Invalid argument.\nYou must pass  Valid arguments are:\n 'concise' 'full'"
  Process.exit
end

query = ARGV[1].gsub(' ', '+')
