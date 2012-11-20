require 'find'
require 'fog'

module Travis::Artifacts
  class Uploader
    attr_accessor :paths, :job_id

    def initialize(paths, job_id)
      self.paths  = paths
      self.job_id = job_id
    end

    def upload
      files.each do |file|
        bucket.files.create({
          key: File.join(prefix, file.destination),
          public: true,
          body: file.read,
          content_type: file.content_type,
          metadata: { "Cache-Control" => 'public, max-age=315360000'}
        })
      end
    end

    def prefix
      "artifacts/#{job_id}"
    end

    def files
      files = []

      paths.each do |artifact_path|
        to   = artifact_path.to
        from = artifact_path.from
        root = artifact_path.root

        if artifact_path.directory?
          root = File.join(root, from)
          root << '/' unless root =~ /\/$/
        end

        Find.find(artifact_path.fullpath) do |path|
          next unless File.file? path

          relative = path.sub(/#{root}\/?/, '')

          destination = if to
            artifact_path.directory? ? File.join(to, relative) : to
          else
            relative
          end

          files << Artifact.new(path, destination)
        end
      end

      files
    end

    private

    def bucket
      @bucket ||= s3.directories.get(Travis::Artifacts.bucket_name)
    end

    def s3
      @s3 ||= begin
        config = { provider: 'AWS' }.merge Travis::Artifacts.aws_config
        Fog::Storage.new(config)
      end
    end
  end
end
