module Step

  def authenticated_articles_route_spec
    
    spec_file = "#{path}/spec/requests/articles_spec.rb"
    print " > editing requests spec #{spec_file}\n"
    old_given = <<-RUBY
    given "a article exists" do
      Article.all.destroy!
      request(resource(:articles), :method => "POST", 
        :params => { :article => { :id => nil }})
    end
  RUBY
    
    gsub_file spec_file, /(^given.*?end)/mi do |match| 
      <<-RUBY    
given "a article exists" do
  Article.all.destroy!
  User.all.detroy!
  u = User.new(:login => "mattetti")
  u.password = u.password_confirmation = "sekrit"
  u.save
  request("/login", :method => "put", :params => {"login" => "mattetti", "password" => "sekrit"})
  request(resource(:articles), :method => "POST", 
    :params => { :article => {:title => 'intro', :author => 'Matt', :created_at => '2008-11-07 10:07:12' }})
end
      RUBY
  end
    
    add_login_spec_helpers
  end
  
  def add_login_spec_helpers
    test_helpers = <<-RUBY 
    
Merb::Test.add_helpers do

  def create_default_user
    if User.first(:login => "krusty").nil?
      request(resource(:users), {
        :method => "POST",
        :params => {
          :user => {
            :login => "krusty",
            :password => "klown",
            :password_confirmation => "klown"
          }
        }
      })
    end
  end
  
  def login
    @response = request("/login", {
      :method => "PUT",
      :params => {
        :login => "krusty",
        :password => "klown"
      }
    })
  end
  
end

    RUBY
    
    append_to_file("#{path}/spec/spec_helper.rb", "#{test_helpers}")      
  end

end