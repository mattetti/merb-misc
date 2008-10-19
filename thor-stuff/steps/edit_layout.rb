module Step
  
  def edit_layout
    print " > editing the layout\n"

    sentinel = "<%#= message[:notice] %>"
    layout_file = "#{path}/app/views/layout/application.html.erb"
    gsub_file layout_file, /(#{Regexp.escape(sentinel)})/mi do |match|
      <<-RUBY 
<%= message[:notice] %>
    <%= message[:error] %>
RUBY
    end

  end
    
end