module Travis::Artifacts
  class Prefix
    attr_reader :prefix, :test

    def initialize(prefix)
      @prefix = prefix
      @test   = Test.new
    end

    def to_s
      prefix.gsub(/\{\{([^\}]+)\}\}/) do |match|
        if possible_replacements.include? $1
          test.send $1
        else
          match
        end
      end
    end

    def possible_replacements
      %w/job_id job_number build_id build_number/
    end
  end
end
