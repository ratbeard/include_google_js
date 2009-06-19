require 'ostruct'

module IncludeGoogleJs
  class JsLibrary < OpenStruct
    
    # TODO justify text!
    def formated
      "#{name}     |  #{versions.reverse.join(", ")}"
    end
      
    # TODO
    def download(opts={})
      opts[:version] ||= latest_version
      # ...
    end
           
    # TODO
    def uri(opts={})
      version = opts[:version] || latest_version
      "http://#{version}"
    end
    
    def latest_version
      versions.last
    end
  end
end