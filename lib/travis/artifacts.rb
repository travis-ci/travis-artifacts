module Travis
  autoload :Client, 'travis/client'

  module Artifacts
    autoload :Cli,      'travis/artifacts/cli'
    autoload :Uploader, 'travis/artifacts/uploader'
    autoload :Artifact, 'travis/artifacts/artifact'
    autoload :Path,     'travis/artifacts/path'

    def self.aws_config
      { aws_access_key_id: ENV['ARTIFACTS_AWS_ACCESS_KEY_ID'],
        aws_secret_access_key: ENV['ARTIFACTS_AWS_SECRET_ACCESS_KEY'],
        region: ENV['ARTIFACTS_AWS_REGION'] || 'us-east-1'
      }
    end

    def self.bucket_name
      ENV['ARTIFACTS_S3_BUCKET']
    end
  end
end
