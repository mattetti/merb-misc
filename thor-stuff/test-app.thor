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
    Dir.chdir(Dir.pwd + "/" + @app_name) do
      print "cd #{@app_name} && rake spec\n"
      print `rake spec`
    end
    # puts 'then `http://localhost:4000/articles`'
  end
  
  protected
  
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
    Dir.chdir(Dir.pwd + "/" + @app_name) do
      `merb-gen resource article title:String,author:String,created_at:DateTime`
    end
  end
  
  def migrate_db
    Dir.chdir(Dir.pwd + "/" + @app_name) do
      `rake db:automigrate MERB_ENV=test`
    end
  end
  
  def edit_request_specs
    print " > editing the request specs\n"
    
    sentinel = ":params => { :article => {  }})"
    spec_file = "#{Dir.pwd}/#{@app_name}/spec/requests/articles_spec.rb"
    gsub_file spec_file, /(#{Regexp.escape(sentinel)})/mi do |match|
      ":params => { :article => {:title => 'intro', :author => 'Matt', :created_at => '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}' }})"
    end
  end
  
  def edit_index_view
    spec_file = "#{Dir.pwd}/#{@app_name}/app/views/articles/index.html.erb"
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
    spec_file = "#{Dir.pwd}/#{@app_name}/spec/requests/articles_spec.rb"
    gsub_file spec_file, /(#{Regexp.escape(sentinel)})/mi do |match| 
      ""
    end
  end

end