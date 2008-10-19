#!/usr/bin/env ruby

class TestApp < Thor 

  desc "generate APP_NAME", "generate a test apps" 
  def generate(name='test-app')
    @app_name = name
    remove_old_generated_app
    generate_app
    generate_article_resource
    migrate_db
    edit_request_specs
    edit_index_view
    make_specs_not_pending
    add_model_validation
    add_model_specs
    edit_layout
    run_app_specs
  end
  
  protected
  
  def app_path
    "#{Dir.pwd}/#{@app_name}"
  end
  
  def gsub_file(destination, regexp, *args, &block)
    path = destination
    content = File.read(path).gsub(regexp, *args, &block)
    File.open(path, 'wb') { |file| file.write(content) }
  end
  
  def remove_old_generated_app
    Dir["#{@app_name}"].each { |old| FileUtils.rm_rf old } 
  end
  
  def generate_app
    puts "generating a test app called: #{@app_name}"
    `merb-gen app #{@app_name}`
  end
  
  def generate_article_resource
    Dir.chdir(app_path) do
      `merb-gen resource article title:String,author:String,created_at:DateTime`
    end
  end
  
  def migrate_db
    Dir.chdir(app_path) do
      `rake db:automigrate MERB_ENV=test`
    end
  end
  
  def edit_layout
    print " > editing the layout\n"
    
    sentinel = "<%#= message[:notice] %>"
    layout_file = "#{app_path}/app/views/layout/application.html.erb"
    gsub_file layout_file, /(#{Regexp.escape(sentinel)})/mi do |match|
      <<-RUBY 
<%= message[:notice] %>
    <%= message[:error] %>
RUBY
    end
    
  end
  
  def edit_request_specs
    print " > editing the request specs\n"
    
    sentinel = ":params => { :article => { :id => nil }})"
    spec_file = "#{app_path}/spec/requests/articles_spec.rb"
    gsub_file spec_file, /(#{Regexp.escape(sentinel)})/mi do |match|
      ":params => { :article => {:title => 'intro', :author => 'Matt', :created_at => '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}' }})"
    end
    
    ### failing_post_spec
    failing_post_spec = <<-RUBY
  \n
  describe "a failing POST" do
    before(:each) do
      @response = request(resource(:articles), :method => "POST", :params => { :article => { :id => nil}})
    end

    it "should re render the new action" do
      @response.body.include?("Articles controller, new action").should be_true
    end
    
    it "should have an error message" do
      @response.body.include?("Article failed to be created").should be_true
    end
  end
RUBY

    gsub_file spec_file, /(end\n\n)$/i do |match|
      "#{failing_post_spec}\n#{match}"
    end

    add_delete_spec
  end
  
  def add_delete_spec
    spec_file = "#{app_path}/spec/requests/articles_spec.rb"
    spec = <<-RUBY
 describe "a succesful DELETE" do
   before(:each) do
     Article.all.destroy!
     request(resource(:articles), :method => "POST", 
       :params => { :article => {:title => 'intro', :author => 'Matt', :created_at => '2008-10-19 02:26:33' }})
     @response = request(resource(:articles), :method => "DELETE", :params => { :id => Article.first.id})
   end

   it "should redirect to the index" do
     @response.body.should include("Articles controller, index action")
     @response.should redirect_to(resource(:articles))
   end
   
 end
RUBY

    gsub_file spec_file, /(end\n\n)$/i do |match|
      "#{spec}\n#{match}"
    end
    
  end
  
  def edit_index_view
    spec_file = "#{app_path}/app/views/articles/index.html.erb"
    print " > editing index view #{spec_file}\n"
    index_view = <<-RUBY 
<ul>
  <% @articles.each do |article| %>
    <li><label>Title:</label><%= article.title %></li>
  <% end %>
</ul>
RUBY
    gsub_file spec_file, /(<a.*<\/a>)/mi do |match| 
      "#{match}\n#{index_view}" 
    end
  end
  
  def make_specs_not_pending
    print " > removing the spec pending status\n"
    sentinel = "pending"
    spec_file = "#{app_path}/spec/requests/articles_spec.rb"
    gsub_file spec_file, /(#{Regexp.escape(sentinel)})/mi do |match| 
      ""
    end
  end
  
  def add_model_validation
    print " > adding title validation to Article\n"
    model_file = "#{app_path}/app/models/article.rb"
    gsub_file model_file, /(end)\s*$/mi do |match|
      "  validates_present :title\n#{match}"
    end
  end
  
  def add_model_specs
    print " > adding model specs\n"
    model_spec = "#{app_path}/spec/models/article_spec.rb"
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
  
  def run_app_specs
    Dir.chdir(Dir.pwd + "/" + @app_name) do
      print "cd #{@app_name} && rake spec\n"
      print `rake spec`
    end
  end

end