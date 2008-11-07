module Step

  def authenticated_articles_route_spec
    
        spec_file = "#{path}/spec/requests/articles_spec.rb"
        print " > editing requests spec #{spec_file}\n"

        old_given = <<-RUBY 
        given "a article exists" do
          Article.all.destroy!
          request(resource(:articles), :method => "POST", 
            :params => { :article => {:title => 'intro', :author => 'Matt', :created_at => '2008-11-07 10:07:12' }})
        end
    RUBY
    
        gsub_file spec_file, /(#{Regexp.escape(old_given)})/mi do |match| 
          <<-RUBY    
              given "a article exists" do
                Article.all.destroy!
                request(resource(:articles), :method => "POST", 
                  :params => { :article => {:title => 'intro', :author => 'Matt', :created_at => '2008-11-07 10:07:12' }})
                User.all.detroy!
                u = User.new(:login => "mattetti")
                u.password = u.password_confirmation = "sekrit"
                u.save
              end
          RUBY
        end
    
  end

end