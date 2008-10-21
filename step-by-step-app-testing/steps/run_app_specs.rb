module Step

  def run_app_specs
    Dir.chdir(path) do
      print "cd #{name} && rake spec\n"
      print `rake spec`
    end
  end

end