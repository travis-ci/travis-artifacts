require 'travis/artifacts'
require 'fileutils'

FileUtils.mkdir_p "log"
Travis::Artifacts::Logger.output = "log/test.log"

RSpec.configure do |config|
  config.expect_with :rspec, :stdlib
end
