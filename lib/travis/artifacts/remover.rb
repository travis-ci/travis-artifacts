require 'find'
require 'fog'

module Travis::Artifacts
  class Remover
    include Travis::Artifacts::Logger

    attr_reader :paths, :mask

    def initialize(options)
      @paths  = options[:paths]
      @mask   = options[:mask] || false
      @test   = Test.new
    end

    def remove
      if mask
        paths.each do |file|
          if file.include? '*'
            target_directory = File.dirname(file)
            file_name = File.basename(file)

            bucket(target_directory).files.each do |target_file|
              if !!(target_file.key =~ Regexp.new(file_name))
                self.retry do
                  target_file.destroy
                end
              end
            end
          else
            remove_file(file)
          end
        end
      else
        paths.each do |file|
          remove_file(file)
        end
      end
    end

    def remove_file(file)
      self.retry do
        _remove(file)
      end
    end

    def retry(&block)
      retries = 0

      begin
        block.call()
      rescue StandardError => e
        if retries < 2
          logger.info "Attempt to remove failed, retrying"
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

    def _remove(file)
      destination = file.sub(/^\//, '')
      logger.info "Remove file #{destination}, public: #{@public}"

      target_file = bucket.files.get(destination)
      if target_file.nil?
        raise Exception.new("File not found #{destination}")
      else
        target_file.destroy
      end
    end

    private

    def job_id
      test.job_id
    end

    def bucket(prefix = nil)
      @bucket ||= s3.directories.get(Travis::Artifacts.bucket_name, prefix: prefix)
    end

    def s3
      @s3 ||= begin
        config = { :provider => 'AWS' }.merge Travis::Artifacts.aws_config
        Fog::Storage.new(config)
      end
    end
  end
end
