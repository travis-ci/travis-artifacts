require 'find'
require 'fog'

module Travis::Artifacts
  class Uploader
    include Travis::Artifacts::Logger

    attr_reader :paths, :target_path

    def initialize(paths, options = {})
      @paths  = paths
      @test   = Test.new
      @public = ! (options[:private]||false)
      @target_path = options[:target_path] || "artifacts/#{@test.build_number}/#{@test.job_number}"
      @cache_control = options[:cache_control] || 'public, max-age=315360000'
    end

    def upload
      files.each do |file|
        upload_file(file)
      end
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


    def upload_file(file)
      retries = 0

      begin
        _upload(file)
      rescue StandardError => e
        if retries < 2
          logger.info "Attempt to upload failed, retrying"
          retries += 1
          retry
        else
          if e.respond_to?(:request)
            # we don't want to display sensitive data, make the error message simpler
            request  = e.request
            response = e.response
            raise e.class.new("Expected(#{request[:expects].inspect}) <=> Actual(#{response.status})")
          else
            raise
          end
        end
      end
    end

    def _upload(file)
      destination = File.join(target_path, file.destination)

      logger.info "Uploading file #{file.source} to #{destination}, public: #{@public}"

      bucket.files.create({
        :key => destination,
        :public => @public,
        :body => file.read,
        :content_type => file.content_type,
        :metadata => { "Cache-Control" => cache_control }
      })
    end

    private

    def job_id
      test.job_id
    end

    def bucket
      @bucket ||= s3.directories.get(Travis::Artifacts.bucket_name)
    end

    def s3
      @s3 ||= begin
        config = { :provider => 'AWS' }.merge Travis::Artifacts.aws_config
        Fog::Storage.new(config)
      end
    end

    def cache_control
      @public ? @cache_control.to_s : 'private'
    end
  end
end
