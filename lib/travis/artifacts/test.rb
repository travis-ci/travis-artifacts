module Travis::Artifacts
  class Test
    def success?
      ENV['TRAVIS_TEST_RESULT'].to_i == 0
    end

    def failure?
      !success?
    end

    def build_number
      ENV['TRAVIS_BUILD_NUMBER']
    end

    def build_id
      ENV['TRAVIS_BUILD_ID']
    end

    def job_number
      ENV['TRAVIS_JOB_NUMBER']
    end

    def job_id
      ENV['TRAVIS_JOB_ID']
    end
  end
end
