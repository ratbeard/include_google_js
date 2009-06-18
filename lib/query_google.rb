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
            require 'pp'
            pp attrs
            IncludeGoogleJs::JsLibrary.new(attrs)
          }
      end                                
      
      def extract_lib_attributes(lib_html)
        # require 'rubygems'; require 'ruby-debug'; debugger
        (lib_html / 'dd.al-libstate').inject({}) do |accum, prop|
          # inner_text looks like:  "name: jquery"
          key, val = prop.inner_text.split
          accum[key.strip] = val.strip
          accum
        end
        
      end




    end

  end
end