require "test/unit"

$:.unshift(File.dirname(__FILE__) + '/../lib')
require "query_google"
include IncludeGoogleJs


class TestQueryGoogle < Test::Unit::TestCase
  
  def test_fetch_returns_html
    result = Query::Google.new.fetch
    assert_match(/<div/, result)
  end                                        
  
  def test_multiple_libraries_returned
    result = Query::Google.new.libs
    assert(result.length > 3)
    assert
  end
  
  
end