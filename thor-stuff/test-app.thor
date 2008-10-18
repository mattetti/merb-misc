#!/usr/bin/env ruby

class TestApp < Thor 

  desc "generate APP_NAME", "generate a test apps" 
  def generate(name)
    Dir["#{name}"].each { |old| FileUtils.rm_rf old }  
    puts "generating a test app called: #{name}"
    `merb-gen app #{name}`
    Dir.chdir(Dir.pwd + "/" + name) do
      `merb-gen resource article title:String,author:String,created_at:DateTime`
      `rake db:automigrate`
    end
    
    puts "run `cd #{name} && merb`"
    puts "then `http://localhost:4000/articles`"
  end

end