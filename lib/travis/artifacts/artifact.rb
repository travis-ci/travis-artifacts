require 'mime/types'

module Travis::Artifacts
  class Artifact < Struct.new(:source, :destination)
    def content_type
      if MIME::Types.type_for(source).any?
        MIME::Types.type_for(source).first.content_type
      else
        'application/octet-stream'
      end
    end

    def read
      File.read(source)
    end
  end
end
