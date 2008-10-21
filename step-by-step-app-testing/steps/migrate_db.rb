module Step
  def migrate_db
    puts " > automigrating the database"
    Dir.chdir(path) do
      `rake db:automigrate MERB_ENV=test`
    end
  end
end