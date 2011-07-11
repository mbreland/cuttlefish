class Scrape < Search

  def initialize(array)
    raw_pages = scrape_cities_from_array(array)
    #raw_pages = scrape_cities_threaded(links)
    postings_unsorted = get_postings(raw_pages) 
    postings_unsorted.first
    postings = remove_duplicates(postings_unsorted)
    puts "found #{postings.count} postings"
    display_in_browser(postings)
  end
  
  def display_in_browser(postings)
    displayClass = Display.new(postings)
    displayClass.format_postings_to_hash
    template = File.open("./public/layout.html").read
    renderer = ERB.new(template)
    displayClass.to_output_file(renderer.result(displayClass.get_binding))
  end
  
  def scrape_cities_from_array(array)
    @@threads = []
    @@pages = []
    @@links = array
    SimpleProgressbar.new.show("Grabbing page source from #{@@links.length} cities") do 
      @@links.each_with_index do |url, index|
        @@threads << Thread.new(url) { |scrape_url|
          begin
            sdoc = Nokogiri::HTML(open(scrape_url[2])).at_css("blockquote")
            scrape_url << sdoc
            @@pages << scrape_url
          rescue OpenURI::HTTPError => error
            
          rescue RuntimeError => error
            puts error
          end 
        }
      progress (((index + 1).to_f / @@links.length)*100).to_i
      end
    end
    @@threads.each { |t| t.join }
    @@pages
  end
  
  def scrape_cities_threaded(links)
    @@threads = []
    @@pages = []
    @@links = links
    SimpleProgressbar.new.show("Grabbing page source from #{@@links.length} cities") do    
      @@links.each_with_index do |url, index|
        @@threads << Thread.new(url) { |scrape_url|
          begin
            #open with nokogiri
            sdoc = Nokogiri::HTML(open(scrape_url)).at_css("blockquote")
            @@pages << sdoc
          rescue OpenURI::HTTPError => error
            puts error.message
          rescue RuntimeError => error
            puts error
          end 
        }
      progress (((index + 1).to_f / @@links.length)*100).to_i
      end
    end
    @@threads.each { |t| t.join }
    @@pages
  end
  
  
  def get_postings(raw_pages)
    @@the_good_stuff = []
    @@raw_pages = raw_pages
    SimpleProgressbar.new.show("Extracting and formatting links ...") do    
      @@raw_pages.each_with_index do |poop, index|
   
        search = poop[3].xpath("//body/blockquote/p")
        search.each do |link|
          link_formatted = link.at_css("a")
          unless link.nil?
            location = link.at_css('font').nil? ? "( o_O )" : link.at_css('font').inner_text
            date = link.inner_text.scan(/(...\s.\d)/).to_s
            @@the_good_stuff << [poop[0], poop[1], date, link_formatted['href'], location, link_formatted.text]
          end
        end
    
        progress (((index + 1).to_f / @@raw_pages.length)*100).to_i 
      end
    end
    @@the_good_stuff
  end
  
  def remove_duplicates(postings) 
    test_array = postings.map {|x| x[3] }
    unique_posts = []
    new_array = []
    postings.each do |post|
      unique_posts << post if test_array.count(post[3]) < 1 || !unique_posts.flatten.include?(post[3]) 
    end
    unique_posts
  end
  
end
