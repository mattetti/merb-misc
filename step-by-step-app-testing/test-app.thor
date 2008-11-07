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

end


class App < Thor 
  
  steps = Dir["#{Dir.pwd}/steps/**.rb"]
  puts "loading #{steps.size} steps"
  steps.each { |file| require file }
  
  include Step

  desc "generate APP_NAME", "generate a test apps" 
  def generate(app_name='my-first-app')
    Step.app_name = app_name
    
    step :preinit_remove_old_generated_app
    step :generate_app_and_git_init
    step :generate_article_resource
    step :migrate_db
    step :edit_request_specs
    step :edit_index_view
    step :make_specs_not_pending
    step :add_model_validation
    step :add_model_specs
    step :edit_layout
    step :authenticate_articles_route
    step :run_app_specs
    step :authenticated_articles_route_spec
    step :run_app_specs
    step :bundling_merb
    step :run_app_specs
  end  

end