module Step

  def run_app_specs
    Dir.chdir(path) do
      puts "cd #{name} && rake spec --trace\n"
      puts `rake spec --trace`
    end
  end

end