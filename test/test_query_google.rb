require "test/unit"

$:.unshift(File.dirname(__FILE__) + '/../lib')
require "query_google"


class TestQueryGoogle < Test::Unit::TestCase            
  # use this method in tests.
  # memoized so only download google page once          
  def google
    @gooooog ||= IncludeGoogleJs::Query::Google.new
  end
    
  def test_fetch_returns_html
    assert_match(/<div/, google.fetch)
  end                                        
  
  # Google has commited to always make these libs available
  # so it is safe to hardcode them in tests.
  # only maintainence issue is to add more as they become available
  def test_expected_libraries_returned
    # given
    libs = google.libs
    lib_names = libs.map {|l| l.name }      
    # then
    assert(libs.length >= 9)
    assert(lib_names.include?('swfobject'))
    assert(lib_names.include?('jquery'))  
    assert(lib_names.include?('jqueryui'))  
    assert(lib_names.include?('prototype'))  
    assert(lib_names.include?('scriptaculous'))  
    assert(lib_names.include?('mootools'))  
    assert(lib_names.include?('dojo'))  
    assert(lib_names.include?('yui'))      
    assert(lib_names.include?('ext-core'))
    #                 
    assert(! lib_names.include?('atlas'))
    assert(! lib_names.include?('jQuery'))               
  end
  
  # google has commited to maintain all versions of libraries
  def test_js_library_versions
    # given
    libs = google.libs
    jquery = libs.find {|lib| lib.name == 'jquery'}
    # then
    assert(jquery.versions.length >= 5)
    assert(jquery.versions.include?('1.3.2'))
  end
end