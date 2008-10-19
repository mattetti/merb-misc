module Step
  
  def edit_index_view
    spec_file = "#{path}/app/views/articles/index.html.erb"
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
  
end