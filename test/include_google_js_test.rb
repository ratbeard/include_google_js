require 'test_helper'

class IncludeGoogleJsTest < Test::Unit::TestCase
  
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::AssetTagHelper

  def test_javascript_defaults_tag_with_google
    string           = javascript_include_tag(:defaults, :include_google_js => true)
    matched_values   = ["google.load(\"prototype\", \"1.6.0.3\")", "google.load(\"scriptaculous\", \"1.8.2\")", "src=\"/javascripts/application.js"]
    unmatched_values = ["src=\"/javascripts/prototype.js", "src=\"/javascripts/effects.js", "src=\"/javascripts/dragdrop.js", "src=\"/javascripts/controls.js"]
    
    should_match(string, matched_values)
    should_not_match(string, unmatched_values)
  end
  
  def test_javascript_defaults_tag_without_google
    string           = javascript_include_tag(:defaults, :include_google_js => false)
    matched_values   = ["src=\"/javascripts/prototype.js", "src=\"/javascripts/effects.js", "src=\"/javascripts/dragdrop.js", "src=\"/javascripts/controls.js", "src=\"/javascripts/application.js"]
    unmatched_values = ["google.load(\"prototype\", \"1.6.0.3\")", "google.load(\"scriptaculous\", \"1\")"]
    
    should_match(string, matched_values)
    should_not_match(string, unmatched_values)
  end
  
  def test_javascript_tag_for_prototype_with_google
    string           = javascript_include_tag("prototype", :include_google_js => true)
    matched_values   = ["google.load(\"prototype\", \"1.6.0.3\")"]
    unmatched_values = ["src=\"/javascripts/prototype.js"]
    
    should_match(string, matched_values)
    should_not_match(string, unmatched_values)
  end
  
  def test_javascript_tag_for_prototype_with_google_and_declared_version
    string           = javascript_include_tag("prototype", :include_google_js => true, :versions => {:prototype => "1.5"})
    matched_values   = ["google.load(\"prototype\", \"1.5\")"]
    unmatched_values = ["src=\"/javascripts/prototype.js"]
    
    should_match(string, matched_values)
    should_not_match(string, unmatched_values)
  end
  
  def test_javascript_tag_for_prototype_with_google_and_cache
    ActionController::Base.perform_caching = true
    string           = javascript_include_tag("prototype", :include_google_js => true, :cache => true)
    matched_values   = ["src=\"/javascripts/all.js"]
    unmatched_values = ["google.load(\"prototype\", \"1.6.0.3\")"]
    
    should_match(string, matched_values)
    should_not_match(string, unmatched_values)
  end
  
  def test_javascript_tag_for_prototype_without_google
    string           = javascript_include_tag("prototype", :include_google_js => false)
    matched_values   = ["src=\"/javascripts/prototype.js"]
    unmatched_values = ["google.load(\"prototype\", \"1.6.0.3\")"]
    
    should_match(string, matched_values)
    should_not_match(string, unmatched_values)
  end
  
  # def test_javascript_tag_for_scriptaculous_with_google
  #   string           = javascript_include_tag("scriptaculous", :include_google_js => true)
  #   matched_values   = ["google.load(\"prototype\", \"1.6.0.3\")", "google.load(\"scriptaculous\", \"1.8.2\")"]
  #   unmatched_values = ["src=\"/javascripts/prototype.js"]
  #   
  #   should_match(string, matched_values)
  #   should_not_match(string, unmatched_values)
  # end
  # 
  # def test_javascript_tag_for_scriptaculous_without_google
  #   string           = javascript_include_tag("scriptaculous", :include_google_js => false)
  #   matched_values   = ["src=\"/javascripts/prototype.js", "src=\"/javascripts/scriptaculous.js"]
  #   unmatched_values = ["google.load(\"prototype\", \"1.6.0.3\")", "google.load(\"scriptaculous\", \"1.8.2\")"]
  #   
  #   should_match(string, matched_values)
  #   should_not_match(string, unmatched_values)
  # end
  
  def test_javascript_tag_for_jquery_with_google
    string           = javascript_include_tag("jquery", :include_google_js => true)
    matched_values   = ["google.load(\"jquery\", \"1.3.2\")"]
    unmatched_values = ["src=\"/javascripts/jquery.js"]
    
    should_match(string, matched_values)
    should_not_match(string, unmatched_values)
  end
  
  def test_javascript_tag_for_jquery_without_google
    string           = javascript_include_tag("jquery", :include_google_js => false)
    matched_values   = ["src=\"/javascripts/jquery.js"]
    unmatched_values = ["google.load(\"jquery\", \"1.3.2\")"]
    
    should_match(string, matched_values)
    should_not_match(string, unmatched_values)
  end
  
  # def test_javascript_tag_for_jquery_ui_with_google
  #   string           = javascript_include_tag("jquery-ui", :include_google_js => true)
  #   matched_values   = ["google.load(\"jquery\", \"1.3.2\")", ]
  #   unmatched_values = ["src=\"/javascripts/jquery.js"]
  #   
  #   should_match(string, matched_values)
  #   should_not_match(string, unmatched_values)
  # end
  # 
  # def test_javascript_tag_for_jquery_ui_without_google
  #   string           = javascript_include_tag("jquery-ui", :include_google_js => false)
  #   matched_values   = ["src=\"/javascripts/jquery.js"]
  #   unmatched_values = ["google.load(\"jquery\", \"1.3.2\")"]
  #   
  #   should_match(string, matched_values)
  #   should_not_match(string, unmatched_values)
  # end
  
  def test_javascript_tag_for_all_with_google
    string           = javascript_include_tag(:all, :include_google_js => true)
    matched_values   = ["google.load(\"prototype\", \"1.6.0.3\")", "google.load(\"scriptaculous\", \"1.8.2\")", "src=\"/javascripts/application.js","google.load(\"jquery\", \"1.3.2\")", "application.js"]
    unmatched_values = ["src=\"/javascripts/jquery.js"]
    
    should_match(string, matched_values)
    should_not_match(string, unmatched_values)
  end
  
  def test_javascript_tag_for_all_without_google
    string           = javascript_include_tag(:all, :include_google_js => false)
  
    matched_values   = ["src=\"/javascripts/jquery.js"]
    unmatched_values = ["google.load(\"jquery\", \"1.3.2\")"]
    
    should_match(string, matched_values)
    should_not_match(string, unmatched_values)
  end
  
  # JS Library Parsing  
  def test_parsing_prototype_for_version
    assert_equal "1.6.0.3", IncludeGoogleJs.parse_prototype if js_exists("prototype")
  end
  
  def test_parsing_scriptaculous_for_version
   assert_equal "1.8.2", IncludeGoogleJs.parse_scriptaculous if js_exists("scriptaculous")
  end
  
  def test_parsing_jquery_for_version
   assert_equal "1.3.2", IncludeGoogleJs.parse_jquery if js_exists("jquery")
  end
  
  def test_parsing_jquery_ui_for_version
   assert_equal "1.7.2", IncludeGoogleJs.parse_jquery_ui if js_exists("jqueryui")
  end
  
  def test_parsing_mootools_for_version
   assert_equal "1.2.2", IncludeGoogleJs.parse_mootools if js_exists("mootools")
  end
  
  def test_parsing_dojo_for_version
   assert_equal "1.3.1", IncludeGoogleJs.parse_dojo if js_exists("dojo")
  end
  
  def test_parsing_yui_for_version
   assert_equal "2.7.0", IncludeGoogleJs.parse_yui if js_exists("yui")
  end
  
  def test_parsing_swfobject_for_version
   assert_equal "2.1", IncludeGoogleJs.parse_swfobject if js_exists("swfobject")
  end
  
  # IncludeGoogleJs.expand_javascript_sources(sources)
  def test_all_sources_with_google_js
    source = [:all]
    use_google_js = true
    libraries = IncludeGoogleJs.expand_javascript_sources(source,use_google_js)
    assert libraries["google"].include?("prototype")
    assert libraries["google"].include?("scriptaculous")
    assert libraries["google"].include?("jquery")
    assert libraries["google"].include?("jquery-ui")
    assert libraries["google"].include?("dojo")
    assert libraries["google"].include?("mootools")
    assert !libraries["google"].include?("application")
    assert libraries["local"].include?("application")
  end
  
  # IncludeGoogleJs.expand_javascript_sources(sources)
  def test_all_sources_without_google_js
    source = [:all]
    use_google_js = false
    libraries = IncludeGoogleJs.expand_javascript_sources(source,use_google_js)
    assert !libraries["google"].include?("prototype")
    assert !libraries["google"].include?("scriptaculous")
    assert !libraries["google"].include?("jquery")
    assert !libraries["google"].include?("jquery-ui")
    assert !libraries["google"].include?("dojo")
    assert !libraries["google"].include?("mootools")
    assert !libraries["google"].include?("application")
    
    assert libraries["local"].include?("prototype")
    assert libraries["local"].include?("scriptaculous")
    assert libraries["local"].include?("jquery")
    assert libraries["local"].include?("jquery-ui")
    assert libraries["local"].include?("dojo")
    assert libraries["local"].include?("mootools")
    assert libraries["local"].include?("application")
  end
  
  def test_defaults_sources_with_google_js
    source = [:defaults]
    use_google_js = true
    libraries = IncludeGoogleJs.expand_javascript_sources(source,use_google_js)
    assert libraries["google"].include?("prototype")
    assert libraries["google"].include?("scriptaculous")
    assert !libraries["google"].include?("application")
    assert !libraries["google"].include?("jquery")
    assert libraries["local"].include?("application")
  end
  
  def test_defaults_sources_without_google_js
    source = [:defaults]
    use_google_js = false
    libraries = IncludeGoogleJs.expand_javascript_sources(source,use_google_js)
    assert !libraries["google"].include?("prototype")
    assert !libraries["google"].include?("scriptaculous")
    assert !libraries["google"].include?("application")
    assert !libraries["google"].include?("jquery")
    
    assert libraries["local"].include?("application")
    assert libraries["local"].include?("prototype")
    assert libraries["local"].include?("controls")
    assert libraries["local"].include?("dragdrop")
    assert libraries["local"].include?("effects")
    assert !libraries["local"].include?("scriptaculous")
  end
  
  def test_given_sources_with_google_js
    source = ["jquery", "jquery-ui", "application"]
    use_google_js = true
    libraries = IncludeGoogleJs.expand_javascript_sources(source,use_google_js)
    assert libraries["google"].include?("jquery")
    assert libraries["google"].include?("jquery-ui")
    assert !libraries["google"].include?("application")
    assert !libraries["google"].include?("prototype")
    assert libraries["local"].include?("application")
  end
  
  def test_given_sources_without_google_js
    source = ["jquery", "jquery-ui", "application"]
    use_google_js = false
    libraries = IncludeGoogleJs.expand_javascript_sources(source,use_google_js)
    assert !libraries["google"].include?("jquery")
    assert !libraries["google"].include?("jquery-ui")
    assert !libraries["google"].include?("application")
    assert !libraries["google"].include?("prototype")
    assert libraries["local"].include?("application")
    assert libraries["local"].include?("jquery")
    assert libraries["local"].include?("jquery-ui")
  end
  
  # helper methods
  def should_match(string="", values=[])
    check_values(string,values,true)
  end
  
  def should_not_match(string="", values=[])
    check_values(string,values,false)
  end

  def check_values(string, values=[], match=true)
    values.each do |value|
      assert match ? string.include?(value) : !string.include?(value), "<#{value}>  was not found in #{string}"
    end
  end
  
  def js_exists(library="")
    case library
      when "yui"
        File.exist?("#{RAILS_ROOT}/public/javascripts/yui/")
      when "swfobject"
        File.exist?("#{RAILS_ROOT}/public/javascripts/swfobject/")
      when "jqueryui"
        File.exist?(File.join(ActionView::Helpers::AssetTagHelper::JAVASCRIPTS_DIR, "jquery-ui.js"))    
      else
        File.exist?(File.join(ActionView::Helpers::AssetTagHelper::JAVASCRIPTS_DIR, "#{library}.js"))    
    end
  end
end