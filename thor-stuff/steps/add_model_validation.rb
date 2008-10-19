module Step
  
  def add_model_validation
    print " > adding title validation to Article\n"
    
    model_file = "#{path}/app/models/article.rb"
    gsub_file model_file, /(end)\s*$/mi do |match|
      "  validates_present :title\n#{match}"
    end
  end
  
end