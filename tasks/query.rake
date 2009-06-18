$:.unshift(File.dirname(__FILE__) + '/../lib')



namespace :javascripts do

  namespace :libs do
   
    desc "List available javascript libraries"
    task :available do
      require "query_google"
      libs = IncludeGoogleJs::Query::Google.new.libs
      puts libs.map {|l| l.formated }
    end

  end

end
