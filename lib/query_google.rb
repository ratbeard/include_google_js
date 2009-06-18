require 'uri'
require 'net/http'
require 'rubygems'
require 'hpricot'

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
        doc / 'dl.al-liblist'
      end    




    end

  end
end