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