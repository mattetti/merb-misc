module Step
  
  def edit_request_specs
    print " > editing the request specs\n"

    ### adding valid params to requests
    sentinel = ":params => { :article => { :id => nil }})"
    spec_file = "#{path}/spec/requests/articles_spec.rb"
    gsub_file spec_file, /(#{Regexp.escape(sentinel)})/mi do |match|
      ":params => { :article => {:title => 'intro', :author => 'Matt', :created_at => '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}' }})"
    end

    ### adding failing_post_spec
    failing_post_spec = <<-RUBY
  \n
  describe "a failing POST" do
    before(:each) do
      @response = request(resource(:articles), :method => "POST", :params => { :article => { :id => nil}})
    end

    it "should re render the new action" do
      @response.body.should include?("Articles controller, new action")
    end

    it "should have an error message" do
      @response.body.include?("Article failed to be created")
    end
  end
  RUBY

    gsub_file spec_file, /(end\n\n)$/i do |match|
      "#{failing_post_spec}\n#{match}"
    end
  end
  
end