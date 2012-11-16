require 'spec_helper'

describe Travis::Artifacts::Cli do
  let(:cli) { described_class.new(argv) }

  before { cli.stub(:upload) }

  context 'with --fetch-config' do
    let(:argv) { ['upload', '--fetch-config'] }
    let(:config) { { 'artifacts' => ['path/to/foo:bar'] } }

    before do
      client = mock('client')
      client.should_receive(:fetch_config).and_return(config)
      cli.client = client
      cli.start
    end

    it 'fetches config from api' do
      cli.paths.map { |p| [p.from, p.to] }.should == [['path/to/foo', 'bar']]
    end
  end

  context 'with multiple paths' do
    let(:argv) { ['upload', '--path', 'path/to/foo', '--path', 'path/to/bar:bar'] }

    before { cli.start }

    it 'parses them' do
      cli.options[:paths].should == ['path/to/foo', 'path/to/bar:bar']
    end

    it 'adds paths to paths array' do
      cli.paths.map { |p| [p.from, p.to] }.should == [['path/to/foo', nil], ['path/to/bar', 'bar']]
    end
  end

  describe '#root' do
    before { cli.start }

    context 'with root passed as an argument' do
      let(:argv) { ['upload', '--root', 'foo'] }
      it 'returns passed value' do
        cli.root.should == 'foo'
      end
    end

    context 'without root passed as an argument' do
      let(:argv) { ['upload'] }
      it 'returns cwd' do
        cli.root.should == Dir.pwd
      end
    end
  end

  context 'with a command' do
    let(:argv) { ['upload'] }

    before { cli.start }

    it 'saves it' do
      cli.command.should == 'upload'
    end
  end
end
