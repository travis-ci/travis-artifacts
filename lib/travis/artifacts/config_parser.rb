module Travis::Artifacts
  class ConfigParser
    attr_reader :config, :artifacts, :test

    def initialize(config)
      @config    = config
      @artifacts = config['artifacts']
      @test      = Test.new
    end

    def paths
      paths  = regular
      paths += on_success if test.success?
      paths += on_failure if test.failure?
      paths
    end

    def regular
      wrap(hash? ? artifacts['artifacts'] : artifacts)
    end

    def on_success
      return [] unless hash?

      wrap artifacts['on_success']
    end

    def on_failure
      return [] unless hash?

      wrap artifacts['on_failure']
    end

    def hash?
      artifacts.is_a? Hash
    end

    def wrap obj
      return [] unless obj

      obj.is_a?(Array) ? obj : [obj]
    end
  end
end
