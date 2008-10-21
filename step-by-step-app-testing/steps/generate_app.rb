module Step
  def generate_app
    puts " > generating a test app called: #{name}"
    
    `merb-gen app #{name}`
  end
end