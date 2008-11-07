Step by Step app testing
====

The goal of this little app is really simple: test each step leading you to the creation of a Merb app.

Each step is wrapped in a different git branch to help with debugging and so people can learn from a step by step generated app.


Usage:
===

		$ thor app:generate optional_app_name

The task above will execute the main scenario and generate our test app using all the steps defined in its scenario.


Development:
===

The defaults steps are available in the steps folder, you can add more steps in the same folder or create your own folder and load your steps:

		my_steps = Dir["#{Dir.pwd}/steps/**.rb"]
		puts "loading #{my_steps.size} steps of my own"
		my_steps.each { |file| require file }
		

If you create a new scenario/task don't forget to specify the app name:

		Step.app_name = app_name
		
To call a step, simply do:

		step :step_name
		
You can prepend your step by "preinit_" to let the step by step tester know that you want to run the task before doing the git init. Add "git_init" to the end of your task to kick the git init task.

Define a step:
===

Steps are just methods inside a Step module. Here is an example of a step:

		module Step
		  def migrate_db
		    puts " > automigrating the database"
		    Dir.chdir(path) do
		      `rake db:automigrate MERB_ENV=test`
		    end
		  end
		end
		
Available methods:

		path (path to the generated app)
		name (name of the generated app)
		gsub_file (replaces part of a file based on a regexp)
		
Here is an example of how to use gsub_file:

    sentinel = "<%#= message[:notice] %>"
    layout_file = "#{path}/app/views/layout/application.html.erb"
    gsub_file layout_file, /(#{Regexp.escape(sentinel)})/mi do |match|
      <<-RUBY 
<%= message[:notice] %>
    <%= message[:error] %>
RUBY
    end

the sentinel is what we are trying to match in the file, layout_file is the file we want to edit and finally we pass a block to replace the matched selection.
