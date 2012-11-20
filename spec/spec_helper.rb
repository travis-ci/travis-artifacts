require 'travis/artifacts'

Travis::Artifacts::Logger.output = "log/test.log"

RSpec.configure do |config|
  config.expect_with :rspec, :stdlib
end
