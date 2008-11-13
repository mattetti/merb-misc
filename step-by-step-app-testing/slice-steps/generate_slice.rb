module Step
  def generate_slice_and_git_init
    puts " > generating a slice called: #{name}"
    
    `merb-gen slice #{name}`
  end
end