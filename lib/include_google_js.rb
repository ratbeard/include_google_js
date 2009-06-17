module IncludeGoogleJs
  require 'ping'
  
  @@javascript_expansions = { :defaults => ActionView::Helpers::AssetTagHelper::JAVASCRIPT_DEFAULT_SOURCES.dup }
  @@default_javascripts = ActionView::Helpers::AssetTagHelper::JAVASCRIPT_DEFAULT_SOURCES.dup
  @@google_js_libs = %w[prototype scriptaculous jquery jquery-ui mootools dojo yui swfobject]
  @@scriptaculous_files = %w[scriptaculous builder controls dragdrop effects slider sound unittest]
  @@default_google_js_libs = %w[prototype scriptaculous]
  @@google_js_to_include = []
  
  def self.included(base) 
    base.alias_method_chain :javascript_include_tag, :google_js
  end
  
  def javascript_include_tag_with_google_js(*sources)
    # split apart the sources, check for :cache, confirm that we're using :include_google_js, and grab :versions
    options                 = sources.extract_options!.stringify_keys
    use_cache               = options.delete("cache")
    javascript_versions     = options.delete("versions") || {}
    use_google_js           = options.delete("include_google_js") && IncludeGoogleJs.confirm_internet_connection
    
    if ActionController::Base.perform_caching && use_cache # Using the locally cached libraries
      joined_javascript_name = (use_cache == true ? "all" : use_cache) + ".js"
      joined_javascript_path = File.join(ActionView::Helpers::AssetTagHelper::JAVASCRIPTS_DIR, joined_javascript_name)

      write_asset_file_contents(joined_javascript_path, compute_javascript_paths(sources))
      return javascript_src_tag(joined_javascript_name, options)
    else
      libraries = IncludeGoogleJs.expand_javascript_sources(sources, use_google_js)
      base_html = libraries["local"].collect { |source| javascript_src_tag(source, options) }.join("\n") # local JS files
      if use_google_js
        html = IncludeGoogleJs.google_script_tags(libraries["google"],javascript_versions)
        html += base_html
      else
        html = base_html
      end
      return html
    end
  end

  def self.expand_javascript_sources(sources,use_google_libraries)
    local_javascript_files  = []
    google_javascript_files = []
    if sources.include?(:all) # All libraries, get everything in the javascripts folder, see which are hosted by Google
      if use_google_libraries
        local_javascript_files += IncludeGoogleJs.all_non_hosted_local_javascript_files
        google_javascript_files += IncludeGoogleJs.all_google_hosted_local_javascript_files
      else
        local_javascript_files += IncludeGoogleJs.all_local_javascript_files
        google_javascript_files += []
      end
    elsif sources.include?(:defaults)
      if use_google_libraries
        local_javascript_files += %w[application]
        google_javascript_files += IncludeGoogleJs.default_sources      
      else
        local_javascript_files += @@default_javascripts + %w[application]
        google_javascript_files += []
      end
    else
      sources = IncludeGoogleJs.check_for_dependencies(sources)
      sources.collect do |source|
        if IncludeGoogleJs.does_google_host?(source) && use_google_libraries
          google_javascript_files << source
        else
          local_javascript_files << source
        end
      end
    end
    return { "google" => google_javascript_files, "local" => local_javascript_files }
  end
  
  def self.check_for_dependencies(source)
    if source.include?("scriptaculous") && !source.include?("prototype")
      source.unshift("prototype")
    elsif source.include?("jquery-ui") && !source.include?("jquery")
      source.unshift("jquery")
    end
    return source
  end
  
  def self.determine_source(source, collection)
    case source
    when Symbol
      collection[source] || raise(ArgumentError, "No expansion found for #{source.inspect}")
    else
      source
    end
  end
  
  def self.google_script_tags(libraries,versions)
    html = %Q{
      <script src='http://www.google.com/jsapi'></script>
      <script>
      }
      libraries.each do |js_lib|
      version = versions.has_key?(js_lib.to_sym) ? versions.fetch(js_lib.to_sym) : IncludeGoogleJs.get_file_version(js_lib)
      html += %Q{google.load("#{js_lib}", "#{version}");
      }
    end
    html += %Q{</script>
      }
  end
  
  def self.determine_if_google_hosts_files(javascript_files)
    @@google_js_to_include = []
    javascript_files.each do |file|
      if @@google_js_libs.include?(file)
        @@google_js_to_include << file
      end
      if @@scriptaculous_files.include?(file)
        @@google_js_to_include << 'scriptaculous' unless @@google_js_to_include.include?('scriptaculous')
      end
    end
    # remove any files from the array if Google hosts it
    @@google_js_to_include.each do |file|
      javascript_files.delete(file)
    end
    # remove all of the scriptaculous files
    @@scriptaculous_files.each do |file|
      javascript_files.delete(file)
    end
    # Sort the Google files to make sure Prototype is loaded before Scriptaculous
    @@google_js_to_include.sort!
    return javascript_files
  end
  
  def self.all_local_javascript_files
    Dir[File.join(ActionView::Helpers::AssetTagHelper::JAVASCRIPTS_DIR, '*.js')].collect { |file| File.basename(file).gsub(/\.\w+$/, '') }.sort
  end
  
  def self.all_google_hosted_local_javascript_files
    all_javascript_files = IncludeGoogleJs.all_local_javascript_files
    all_javascript_files.delete_if { |file| !IncludeGoogleJs.does_google_host?(file) }
    return all_javascript_files
  end
  
  def self.all_non_hosted_local_javascript_files
    all_javascript_files = IncludeGoogleJs.all_local_javascript_files
    all_javascript_files.delete_if { |file| IncludeGoogleJs.does_google_host?(file) }
    all_javascript_files.delete_if { |file| @@scriptaculous_files.include?(file) }
    return all_javascript_files
  end
  
  def self.remove_google_hosted_libraries_from(array)
    google_libraries = []
    array.each do |library|
      google_libraries << library if IncludeGoogleJs.does_google_host?(library)
    end
    google_libraries.each do |library|
      array.delete(library)
    end
    return array
  end
  
  def self.does_google_host?(file)
    @@google_js_libs.include?(file)
  end
  
  def self.default_sources
    sources = []
    sources += @@default_google_js_libs
    return sources
  end
  
  def self.confirm_internet_connection(url="ajax.googleapis.com")    
    Ping.pingecho(url,5,80) # --> true or false  
  end
  
  def self.get_file_version(file)
    version = "1"
    # split file_name for instances where the file has a version number at the end
    # library = file.replace("-","_")
    return IncludeGoogleJs.send("parse_#{file.gsub("-","_")}")
  end
  
  def self.parse_prototype(file="prototype")
    if File.exist?(File.join(ActionView::Helpers::AssetTagHelper::JAVASCRIPTS_DIR, "#{file}.js"))
      File.open(File.join(ActionView::Helpers::AssetTagHelper::JAVASCRIPTS_DIR, "#{file}.js")).each do |line|
        return line.match(/[\d.]+/)[0] if line.include?("Version")
      end
    else
      return nil
    end
  end
  
  def self.parse_scriptaculous(file="scriptaculous")
    if File.exist?(File.join(ActionView::Helpers::AssetTagHelper::JAVASCRIPTS_DIR, "#{file}.js"))
      File.open(File.join(ActionView::Helpers::AssetTagHelper::JAVASCRIPTS_DIR, "#{file}.js")).each do |line|
        return line.match(/scriptaculous.js v([\d.]+)/i)[1]
      end
    else
      return nil
    end
  end
  
  def self.parse_jquery(file="jquery")
    if File.exist?(File.join(ActionView::Helpers::AssetTagHelper::JAVASCRIPTS_DIR, "#{file}.js"))
      File.open(File.join(ActionView::Helpers::AssetTagHelper::JAVASCRIPTS_DIR, "#{file}.js")).each do |line|
        version_array = line.scan(/jquery:\W?"([\d.]+)"/x).to_s
        return version_array.to_s unless version_array.blank?
      end
    else
      return nil
    end
  end
  
  def self.parse_jquery_ui(file="jquery-ui")
    if File.exist?(File.join(ActionView::Helpers::AssetTagHelper::JAVASCRIPTS_DIR, "#{file}.js"))
      File.open(File.join(ActionView::Helpers::AssetTagHelper::JAVASCRIPTS_DIR, "#{file}.js")).each do |line|
        version_array = line.scan(/version:\W?"([\d.]+)"/x).to_s
        return version_array.to_s unless version_array.blank?
      end
    else
      return nil
    end
  end
  
  def self.parse_mootools(file="mootools")
    if File.exist?(File.join(ActionView::Helpers::AssetTagHelper::JAVASCRIPTS_DIR, "#{file}.js"))
      File.open(File.join(ActionView::Helpers::AssetTagHelper::JAVASCRIPTS_DIR, "#{file}.js")).each do |line|
        return line.match(/version:["|']([\d\.]+)["|']/i)[1] if line.include?("version")
      end
    else
      return nil
    end
  end
  
  def self.parse_dojo(file="dojo")
    if File.exist?(File.join(ActionView::Helpers::AssetTagHelper::JAVASCRIPTS_DIR, "#{file}.js"))
      version = nil
      File.open(File.join(ActionView::Helpers::AssetTagHelper::JAVASCRIPTS_DIR, "#{file}.js")).each do |line|
        match = line.scan(/\b[major|minor|patch]{5,}:([\d]+)/i)
        if match.size > 0
          version = match.shift.to_s
          match.each do |x|
            version += "."+x.to_s
          end
          return version
        end
      end
    else
      return nil
    end
  end
  
  def self.parse_yui
    if File.exist?(File.join(ActionView::Helpers::AssetTagHelper::JAVASCRIPTS_DIR, "yui/build/yuiloader/yuiloader-min.js"))
      File.open(File.join(ActionView::Helpers::AssetTagHelper::JAVASCRIPTS_DIR, "yui/build/yuiloader/yuiloader-min.js")).each do |line|
        return line.match(/^version: ([\d.]+)/i)[1] if line.match(/^version: ([\d.]+)/i)
      end
    else
      return nil
    end
  end
  
  def self.parse_swfobject
    if File.exist?(File.join(ActionView::Helpers::AssetTagHelper::JAVASCRIPTS_DIR, "yui/build/yuiloader/yuiloader-min.js"))
      File.open(File.join(ActionView::Helpers::AssetTagHelper::JAVASCRIPTS_DIR, "swfobject/swfobject.js")).each do |line|
        return line.match(/SWFObject v([\d\.]+)/i)[1] if line.match(/SWFObject v([\d\.]+)/i)
      end
    else
      return nil
    end
  end
  
end
