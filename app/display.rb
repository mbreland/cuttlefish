class Display 
  attr_accessor :out_file, :postings
  
  def initialize(postings, gig, search) 
    @out_file = "./public/cuttlefish.html"
    @postings = postings
    if File.exists?(@out_file)  
      File.delete(@out_file)
    end
  end
  
  def get_binding
    binding
  end
  
  def format_postings
    @poops = [] 
    @postings.each do |link|
      number = link[0].to_s.scan(/\d+/)
      format_date = number.to_s.to_i < 10 ? link[0].to_s + "&nbsp;" : link[0]
      @poops << " #{format_date} - #{link[1]} - #{link[2]}</br></br>"
    end
  end
  
  def to_output_file(content)
    File.open(@out_file, "w+") do |file|
      file.puts content
    end
    system("open #{@out_file}")
  end
  
end