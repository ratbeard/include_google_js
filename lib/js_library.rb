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
          
    def latest_version
      versions.last
    end
  end
end