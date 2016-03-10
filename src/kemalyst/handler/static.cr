require "html"
require "uri"

module Kemalyst::Handler
  class Static < Base
    property public_folder

    def initialize
      @public_folder = "./public"
    end

    def call(context)
      unless context.request.method == "GET" || context.request.method == "HEAD"
        call_next(context)
        return
      end

      public_dir = File.expand_path(@public_folder)
      request_path = URI.unescape(context.request.path.not_nil!)
      expanded_path = File.expand_path(request_path, "/")
      file_path = File.join(public_dir, expanded_path)
      
      if Dir.exists?(file_path)
        call_next(context)
      elsif File.exists?(file_path)
        context.response.content_type = mime_type(file_path)
        context.response.content_length = File.size(file_path)
        File.open(file_path) do |file|
          IO.copy(file, context.response)
        end
      else
        call_next(context)
      end
    end

    private def mime_type(path)
      case File.extname(path)
      when ".txt"          then "text/plain"
      when ".htm", ".html" then "text/html"
      when ".css"          then "text/css"
      when ".js"           then "application/javascript"
      else                      "application/octet-stream"
      end
    end

  end
end

