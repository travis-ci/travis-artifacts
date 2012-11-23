require 'spec_helper'

module Travis::Artifacts
  describe ConfigParser do
    let(:config) { {} }
    let(:parser) { described_class.new(config) }

    context 'when array is given' do
      let(:config) { { 'artifacts' => ['foo'] } }
      example { parser.on_success.should == [] }
      example { parser.on_failure.should == [] }
      example { parser.regular.should == ['foo'] }
      example { parser.paths.should == ['foo'] }
    end

    context 'when hash is given' do
      let(:config) do
        {
          'artifacts' => {
            'prefix' => 'artifacts/{{job_number}}',
            'artifacts' => ['regular-path'],
            'on_success' => ['on-success-path'],
            'on_failure' => ['on-failure-path']
          }
        }
      end

      it 'fetches prefix' do
        parser.prefix.should == 'artifacts/{{job_number}}'
      end

      context 'with passing test' do
        before { parser.test.stub(success?: true) }
        example { parser.paths.should == ['regular-path', 'on-success-path'] }
      end

      context 'with failing test' do
        before { parser.test.stub(success?: false) }
        example { parser.paths.should == ['regular-path', 'on-failure-path'] }
      end
    end

    context 'with non array values' do
      let(:config) do
        {
          'artifacts' => {
            'artifacts' => 'regular-path',
            'on_success' => 'on-success-path',
            'on_failure' => 'on-failure-path'
          }
        }
      end
      example { parser.on_success.should == ['on-success-path'] }
      example { parser.on_failure.should == ['on-failure-path'] }
      example { parser.regular.should == ['regular-path'] }
    end

    context 'with empty values' do
      let(:config) do
        {
          'artifacts' => {
            'artifacts'  => nil,
            'on_success' => nil,
            'on_failure' => nil
          }
        }
      end
      example { parser.on_success.should == [] }
      example { parser.on_failure.should == [] }
      example { parser.regular.should == [] }
    end
  end
end
