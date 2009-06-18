require "test/unit"

$:.unshift(File.dirname(__FILE__) + '/../lib')
require "query_google"
include IncludeGoogleJs


class TestQueryGoogle < Test::Unit::TestCase
            
            
  # use this method in tests.
  # memoized so only download google page once          
  def google
    @gooooog ||= Query::Google.new
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
    assert(libs.length > 3)
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
    # puts google.libs           
  end
  
                             
  
  def test_js_library_fields
    lib = Query::Google.new.libs.first
    assert_not_nil(lib.name)
    assert_not_nil(lib.versions)
    # assert_not_nil(lib.compressed?)
    # assert_not_nil(lib.compressed?)
    
  end
  
  
end