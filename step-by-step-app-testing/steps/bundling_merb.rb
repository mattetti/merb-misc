module Step
  
  def bundling_merb
    puts "bundling merb and mongrel.. this is going to take a while :("
    puts `thor merb:gem:install merb`
    puts `thor merb:gem:install mongrel`
  end
  
end