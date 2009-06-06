namespace :javascript do
  libraries = %w[prototype scriptaculous jquery mootools dojo yui swfobject]
  namespace :get do
    require 'net/http'
    
    namespace :get do
      rule /^javascript:get/ do |t|
        Rake::Task['environment'].invoke
        root = t.name.gsub("javascript:get:","").split(/:/)
        library = root[0]

        if library == "all"
          exception = root[1] == "except" ? root[2] : nil
          libraries.each do |name|
            get_library(name) unless name == exception
          end
        else
          get_library(library)
        end
      end
    end
    
    def get_library(name="")
      puts "Getting #{name}"
      case name
        when "prototype"
          # Prototype - http://www.prototypejs.org/assets/2008/9/29/prototype-1.6.0.3.js
          Net::HTTP.start('www.prototypejs.org',80) do |http|
            File.open("#{RAILS_ROOT}/public/javascripts/prototype.js", 'w') {
                |f| f.write(http.get('/assets/2008/9/29/prototype-1.6.0.3.js').body)
              }
          end
        when "scriptaculous"
          # Scriptaculous - http://script.aculo.us/dist/scriptaculous-js-1.8.2.zip
          Dir.chdir("#{RAILS_ROOT}/public/javascripts") do
            Net::HTTP.start("script.aculo.us") do |http|
              zip = http.get("/dist/scriptaculous-js-1.8.2.zip")
              open("scriptaculous.zip", 'w') {
                |f| f.write(zip.body)
              }
              `unzip scriptaculous.zip`
              `rm scriptaculous.zip`
              `mv scriptaculous-js-1.8.2/src/* ../javascripts/`
              `rm -rf scriptaculous-js-1.8.2`
            end
          end
        when "jquery"
          # jQuery - http://jqueryjs.googlecode.com/files/jquery-1.3.2.min.js
          Net::HTTP.start('jqueryjs.googlecode.com',80) do |http|
            File.open("#{RAILS_ROOT}/public/javascripts/jquery.js", 'w') {
                |f| f.write(http.get('/files/jquery-1.3.2.min.js').body)
              }
          end
        when "mootools"
          # mootools - http://mootools.net/download/get/mootools-1.2.2-core-yc.js
          Net::HTTP.start('mootools.net',80) do |http|
            File.open("#{RAILS_ROOT}/public/javascripts/mootools.js", 'w') {
                |f| f.write(http.get('/download/get/mootools-1.2.2-core-yc.js').body)
              }
          end
        when "dojo"
          # Dojo - http://download.dojotoolkit.org/release-1.3.1/dojo.js
          Net::HTTP.start('download.dojotoolkit.org',80) do |http|
            File.open("#{RAILS_ROOT}/public/javascripts/dojo.js", 'w') {
                |f| f.write(http.get('/release-1.3.1/dojo.js').body)
              }
          end
        when "yui"
          # YUI - http://yuilibrary.com/downloads/yui2/yui_2.7.0b.zip
          Dir.chdir("#{RAILS_ROOT}/public/javascripts") do
            Net::HTTP.start("yuilibrary.com") do |http|
              zip = http.get("/downloads/yui2/yui_2.7.0b.zip")
              open("yui.zip", 'w') {
                |f| f.write(zip.body)
              }
              `unzip yui.zip`
              `rm yui.zip`
            end
          end
        when "swfobject"
          # swfobject - http://swfobject.googlecode.com/files/swfobject_2_1.zip
          Dir.chdir("#{RAILS_ROOT}/public/javascripts") do
            Net::HTTP.start("swfobject.googlecode.com") do |http|
              zip = http.get("/files/swfobject_2_1.zip")
              open("swfobject.zip", 'w') {
                |f| f.write(zip.body)
              }
              `unzip swfobject.zip`
              `rm swfobject.zip`
            end
          end
        else
          puts "I don't know about #{name}, sorry! Please check for a newer version of include_google_js."
        end
    end
  end
  
  namespace :remove do
    rule /^javascript:remove/ do |t|
      Rake::Task['environment'].invoke
      root = t.name.gsub("javascript:remove:","").split(/:/)
      library = root[0]
      exception = root[1] == "except" ? root[2] : nil
      
      if library == "all"
        libraries.each do |name|
          remove_library(name) unless name == exception
        end
      else
        remove_library(library)
      end
    end
  end
  
  def remove_library(name="")
    case name
      when "yui"
        puts "Removing YUI from /public/javascripts/"
        `rm -rf yui`
      when "scriptaculous"
        puts "Removing Scriptaculous files from /public/javascripts/"
        %w[scriptaculous builder controls dragdrop effects slider sound unittest].each do |file|
          File.delete("#{RAILS_ROOT}/public/javascripts/#{file}.js")
        end
      when "swfobject"
        `rm -rf swfobject`
      else
        if File.exist?(File.join(ActionView::Helpers::AssetTagHelper::JAVASCRIPTS_DIR, "#{name}.js"))
          puts "Removing #{name} from /public/javascripts/"
          File.delete("#{RAILS_ROOT}/public/javascripts/#{name}.js")
        end
      end
  end
end