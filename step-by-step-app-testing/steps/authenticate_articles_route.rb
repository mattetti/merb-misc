module Step
  def authenticate_articles_route
    puts " > authenticating the articles route\n"
    sentinel = "resources :articles"
    route_file = "#{path}/config/router.rb"
    gsub_file route_file, /(#{Regexp.escape(sentinel)})/mi do |match| 
      <<-RUBY
authenticate do
    #{sentinel}  
end
RUBY
    end
  end
end