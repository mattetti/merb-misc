#!/usr/bin/env ruby
require 'extlib'
require 'merb-core'


# TODO: move to a gem so I can package the steps easily
#
module Step

  # setter for the app name
  #
  def self.app_name=(app_name)
    @@app_name = app_name
  end
  
  # name of the generated app
  #
  def name
    @@app_name
  end
  
  # path of the generated app
  #
  def path
    @path ||= "#{Dir.pwd}/#{name}"
  end
  
  # Execute a step
  #
  # steps with preinit in the name won't be wrapped in a git branch
  # step with git_init will trigger a git initialization after being run
  #
  def step(method_name)
    @count ||= 1
    print "- step #{@count} "
    method_name.to_s.match(/preinit_|git_init/) ? send(method_name) : git_step(method_name)
    git_init if method_name.to_s.include?("git_init")
    @count += 1
  end
  
  # replaces part of a file based on a regexp
  #
  def gsub_file(destination, regexp, *args, &block)
    path = destination
    content = File.read(path).gsub(regexp, *args, &block)
    File.open(path, 'wb') { |file| file.write(content) }
  end
  
  # inserts some code at the top a file
  def prepend_to_file(path, text_to_add)
    add_content_to_file(path, text_to_add, :top)
  end
  
  # inserts some code at the bottom of a file
  def append_to_file(path, text_to_add)
    add_content_to_file(path, text_to_add, :bottom)
  end
  
  # Adds content to a file
  # params:
  # path: to the file to edit
  # text_to_add: I bet you can figure this one on your own
  # position: symbol or string, choose between :top and :bottom
  #
  def add_content_to_file(path, text_to_add, position)
    case position.to_s
    when "top"
      content = text_to_add + File.read(path)
    when "bottom"
      content = File.read(path) + text_to_add
    else
      raise "Please specify the position to insert your content (:top or :bottom)"
    end
    File.open(path, 'wb') { |file| file.write(content) }
  end
  
  # initiate a local git repo
  #
  def git_init
    Dir.chdir(path) do
      `git init`
      `git add .` 
      `git commit -a -m "initial generated app"` 
      `git branch step1_fresh-app`
    end
  end
  
  # wraps a step in a git branch
  #
  def git_step(step_name)
    Dir.chdir(path) do
      `git branch step#{@count}_#{step_name}`
      `git checkout step#{@count}_#{step_name}`
      send(step_name)
      puts "commiting the changes"
      `git add .` 
      `git commit -a -m "#{step_name}"`
    end
  end
  
  # Loads steps
  # path the name of the folder containing the steps
  #
  def load_steps(path="shared-steps")
    steps = Dir["#{Dir.pwd}/#{path}/**.rb"]
    steps.each { |file| require file }
  end

end




############################################################################################################
#
# =>  APP Generators
#
############################################################################################################

class App < Thor 
  
  include Step

  desc "generate APP_NAME bundling", "generate a test app, the second param sets bundling testing or not" 
  def generate(app_name='my-first-app', bundling=false)
    Step.app_name = app_name
    load_steps('shared-steps')
    load_steps('steps')
    
    step :preinit_remove_old_generated_app
    step :generate_app_and_git_init
    step :generate_article_resource
    step :migrate_db
    step :add_model_validation
    step :add_model_specs
    
    step :edit_request_specs
    step :edit_index_view
    step :make_specs_not_pending
    step :edit_layout
    step :authenticate_articles_route
    step :authenticated_articles_route_spec
    step :run_app_specs
    if bundling
      step :bundling_merb
      step :run_bundled_app_specs
    end
  end  
  
  desc "generate_very_flat APP_NAME", "generate a very flat test app" 
  def generate_very_flat(app_name="very-flat-app")
    load_steps('shared-steps')
    load_steps('very-flat-steps')
    Step.app_name = app_name
    
    step :preinit_remove_old_generated_app
    step :generate_app_and_git_init
    step :run_app_specs
    
  end

  desc "generate_flat APP_NAME", "generate a flat test app" 
  def generate_flat(app_name="flat-app")
    load_steps('shared-steps')
    load_steps('flat-steps')
    Step.app_name = app_name
    
    step :preinit_remove_old_generated_app
    step :generate_app_and_git_init
    step :run_app_specs
    
  end
  
  desc "generate_core APP_NAME", "generate a core test app" 
  def generate_core(app_name="core-app")
    load_steps('shared-steps')
    load_steps('core-steps')
    Step.app_name = app_name
    
    step :preinit_remove_old_generated_app
    step :generate_app_and_git_init
    step :run_app_specs
    
  end
  
  desc "generate_slice SLICE_NAME", "generate a test slice" 
  def generate_slice(app_name="slice-app")
    load_steps('shared-steps')
    load_steps('slice-steps')
    Step.app_name = app_name
    
    step :preinit_remove_old_generated_app
    step :generate_app_and_git_init
    step :run_app_specs
    
  end
end