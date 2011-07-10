class Display 
  attr_accessor :out_file, :postings
  
  def initialize(postings, gig, search) 
    @out_file = "./tmp/results.html"
    @postings = postings
    if File.exists?(@out_file)  
      File.delete(@out_file)
    end
  end
  
  def get_binding
    binding
  end
  
  def format_postings
    @results = [] 
    @postings.each do |link|
      @results << {"date" => link[0], "link" => link[1], "location" => link[2]}
    end
  end
  
  def to_output_file(content)
    File.open(@out_file, "w+") do |file|
      file.puts content
    end
    system("open #{@out_file}")
  end
  
end