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

      # get html body.  memoized
      def fetch
        @response ||= Net::HTTP.get_response(URI.parse(url).host, URI.parse(url).path)
        @response.body
      end

      # Get list of JsLibraries
      def libs
        @libs ||= 
        (doc / 'dl.al-liblist').map {|lib| 
          attrs = extract_lib_attributes(lib)  
          IncludeGoogleJs::JsLibrary.new(attrs)
        }
      end                                


      private                     
      # hpricot doc of html body.  memoized
      def doc
        @doc ||= Hpricot(fetch)
      end

      # convert an [] of elems to a hash of props
      # calling inner_text gives us a str like:  "name: jquery"      
      # we split it at first ':', then strip out whitespace.
      # Then, call a trasnform on the value.  By default, this
      # just returns the value back.  But this can be overriden
      # based on the key name.  For example, we convert versions
      # in to an array
      def extract_lib_attributes(lib_html)
        transform = Hash.new(lambda {|val| val})
        transform.merge! \
          "versions" => lambda {|val| val.split(', ')}

        (lib_html / 'dd.al-libstate').inject({}) do |accum, prop|
          key, val = prop.inner_text.split(":", 2).map {|s| s.strip}               
          accum[key] = transform[key].call(val)
          accum
        end
      end  
    end
  end
end