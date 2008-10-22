module Step
  def generate_article_resource
    puts " > generating an article resource"
    
    Dir.chdir(path) do
      puts `merb-gen resource article title:String,author:String,created_at:DateTime`
    end
  end
end