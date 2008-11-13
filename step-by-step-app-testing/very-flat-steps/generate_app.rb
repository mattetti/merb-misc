module Step
  def generate_app_and_git_init
    puts " > generating a very flat test app called: #{name}"
    
    `merb-gen very_flat #{name}`
  end
end