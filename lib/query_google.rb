require 'uri'
require 'net/http'
require 'rubygems'
require 'hpricot'

require 'js_library'

module IncludeGoogleJs
  module Query
    class Google

      def url 
        "http://code.google.com/apis/ajaxlibs/documentation/"
      end
      
      # html body.  memoized
      def fetch
        @response ||= Net::HTTP.get_response(URI.parse(url).host, URI.parse(url).path)
        @response.body
      end
                 
      # html body as hpricot doc.  memoized
      def doc
        @doc ||= Hpricot(fetch)
      end
                   
      
      def libs
        @libs ||= 
          (doc / 'dl.al-liblist').map {|lib| 
            attrs = extract_lib_attributes(lib)
            IncludeGoogleJs::JsLibrary.new(attrs)
          }
      end                                
      
      def extract_lib_attributes(lib_html)
        { 
          :name => (doc / '.al-libname').text, 
          :versions => [1,2]
        }
      end




    end

  end
end