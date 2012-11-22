module Travis::Artifacts
  class Test
    def success?
      ENV['TRAVIS_TEST_RESULT'].to_i == 0
    end

    def failure?
      !success?
    end
  end
end
