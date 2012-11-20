require 'logger'

module Travis::Artifacts
  module Logger
    class << self
      attr_accessor :output
    end
    self.output = STDOUT


    attr_reader :logger

    def logger
      @logger ||= ::Logger.new(Travis::Artifacts::Logger.output)
    end
  end
end
