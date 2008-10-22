module Step
  def generate_app_and_git_init
    puts " > generating a test app called: #{name}"
    
    `merb-gen app #{name}`
  end
end