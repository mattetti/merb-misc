module Step
  def generate_app_and_git_init
    puts " > generating a very core test app called: #{name}"
    
    `merb-gen core #{name}`
  end
end