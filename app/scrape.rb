class Scrape

  def initialize(links, gig, search)
    raw_pages = scrape_cities_threaded(links)
    postings = get_postings(raw_pages)
    puts "found #{postings.count} postings"
    display_in_browser(postings, gig, search)
  end
  
  def display_in_browser(postings, gig, search)
    displayClass = Display.new(postings, gig, search)
    displayClass.format_postings
    template = File.open("./public/layout.html").read
    renderer = ERB.new(template)
    displayClass.to_output_file(renderer.result(displayClass.get_binding))
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
        search = poop.xpath("//blockquote/p")
        search.each do |link|
          unless link.nil? || @@the_good_stuff.include?(link) || @@the_good_stuff.include?('!')
            location = link.at_css('font').nil? ? "( o_O )" : link.at_css('font').inner_text
            @@the_good_stuff << [link.inner_text.scan(/(...\s.\d)/), link.at_css("a"), location]
          end
        end
        progress (((index + 1).to_f / @@raw_pages.length)*100).to_i  
      end
    end
    @@the_good_stuff
  end
  
end

class City
  attr_accessor :name
  
  def initialize(name)
    @name = name
  end
end
