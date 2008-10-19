#!/usr/bin/env ruby
require 'extlib'

module Step
  def self.app_name=(app_name)
    @@app_name = app_name
  end
  
  def name
    @@app_name
  end
  
  def path
    "#{Dir.pwd}/#{name}"
  end
  
  def step(method_name)
    @count ||= 1
    print "- step #{@count} "
    send(method_name)
    @count += 1
  end
  
  def gsub_file(destination, regexp, *args, &block)
    path = destination
    content = File.read(path).gsub(regexp, *args, &block)
    File.open(path, 'wb') { |file| file.write(content) }
  end
end


class TestApp < Thor 
  
  steps = Dir["#{Dir.pwd}/steps/**.rb"]
  puts "loading #{steps.size} steps"
  steps.each { |file| require file }
  
  include Step

  desc "generate APP_NAME", "generate a test apps" 
  def generate(app_name='test-app')
    Step.app_name = app_name
    
    step :remove_old_generated_app
    step :generate_app
    step :generate_article_resource
    step :migrate_db
    step :edit_request_specs
    step :edit_index_view
    step :make_specs_not_pending
    step :add_model_validation
    step :add_model_specs
    step :edit_layout
    step :run_app_specs
  end

end