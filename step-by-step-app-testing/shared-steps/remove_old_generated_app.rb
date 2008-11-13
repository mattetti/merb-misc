module Step
  def preinit_remove_old_generated_app
    print " > cleaning up\n"
    Dir["#{name}"].each { |old| FileUtils.rm_rf old } 
  end
end