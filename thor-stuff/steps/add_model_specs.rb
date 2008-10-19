module Step
  
  def add_model_specs
    puts " > adding model specs"
    
    model_spec = "#{path}/spec/models/article_spec.rb"
    validation_spec = <<-RUBY
it "should not be valid without a title" do
    @article = Article.new
    @article.should_not be_valid
  end
  RUBY
    gsub_file model_spec, /(it "should have specs")/mi do |match| 
      validation_spec
    end
  end
    
end