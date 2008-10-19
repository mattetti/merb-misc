module Step
  def make_specs_not_pending
    print " > removing the spec pending status\n"
    sentinel = "pending"
    spec_file = "#{path}/spec/requests/articles_spec.rb"
    gsub_file spec_file, /(#{Regexp.escape(sentinel)})/mi do |match| 
      ""
    end
  end
end