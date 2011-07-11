class Display < Search
  attr_accessor :out_file, :postings, :gig, :query
  
  def initialize(postings) 
    @out_file = "./tmp/results.html"
    @postings = postings
    @gig = $category_full
    @query = $search
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
      @results << {"date" => link[2].to_s.scan(/^\w+\s+\d+/), "link" => link[3], "location" => link[4], "description" => link[5]}
    end
  end
  
  def format_postings_to_hash
    @results = {}
    test_array = @postings.map {|x| x[0] }
    unique_posts = Hash.new do |hash, key|
      hash[key] = {}
    end
    @postings.each do |post|

      if test_array.count(post[0]) < 1 || !unique_posts.has_key?(post[0]) 
        unique_posts[post[0]]["posts"] = [[post[1],post[2].to_s.scan(/^\w+\s+\d+/),post[3],post[4],post[5]]] 
      else
        parent = unique_posts.fetch(post[0])
        parent["posts"] << [post[1],post[2].to_s.scan(/^\w+\s+\d+/),post[3],post[4],post[5]] 
      end
    end
    @results = unique_posts
  end
  
  def to_output_file(content)
    File.open(@out_file, "w+") do |file|
      file.puts content
    end
    system("open #{@out_file}")
  end
  
end