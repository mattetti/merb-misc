module Step
  def generate_app_and_git_init
    puts " > generating a flat test app called: #{name}"
    
    `merb-gen flat #{name}`
  end
end