require 'spec_helper'

module Travis::Artifacts
  describe Prefix do
    let(:test)   { mock('test') }
    before { Test.stub(new: test) }

    it 'replaces {{ }} vars with values from test' do
      test.stub(
        job_id: '5',
        job_number: '10.1',
        build_id: '4',
        build_number: '10'
      )

      prefix = Prefix.new("{{job_id}}/{{job_number}}/{{build_id}}/{{build_number}}")
      prefix.to_s.should == "5/10.1/4/10"
    end

    it 'leaves unknown strings' do
      prefix = Prefix.new("{{foobar}}")
      prefix.to_s.should == "{{foobar}}"
    end
  end
end
