module Step

  def run_bundled_app_specs
    Dir.chdir(path) do
      puts "cd #{name} && bin/rake spec --trace\n"
      puts `bin/rake spec --trace`
    end
  end

end