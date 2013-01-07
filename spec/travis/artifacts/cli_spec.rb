require 'spec_helper'

module Travis::Artifacts
  describe Cli do
    let(:cli) { described_class.new(argv) }


    context 'with multiple paths' do
      before { cli.stub(:upload) }
      let(:argv) { ['upload', '--path', 'path/to/foo', '--path', 'path/to/bar:bar'] }

      before { cli.start }

      it 'parses them' do
        cli.options[:paths].should == ['path/to/foo', 'path/to/bar:bar']
      end

      it 'adds paths to paths array' do
        cli.paths.map { |p| [p.from, p.to] }.should == [['path/to/foo', nil], ['path/to/bar', 'bar']]
      end
    end

    describe 'upload' do
      let(:argv) { ['upload', '--path', 'foo', '--target-path', 'bar'] }
      it 'calls Uploader with given paths and target_path' do
        uploader = mock('uploader')
        Uploader.should_receive(:new).with([Path.new('foo', nil, Dir.pwd)], \
                                          {:paths=>["foo"], :private=>false, :target_path=>"bar"}\
                                          ).and_return(uploader)
        uploader.should_receive(:upload)

        cli.start
      end
    end

    describe '#root' do
      before { cli.stub(:upload) }
      before { cli.start }

      context 'with root passed as an argument' do
        let(:argv) { ['upload', '--root', 'foo'] }
        it 'returns passed value' do
          cli.root.should == 'foo'
        end
      end

      context 'without root passed as an argument' do
        before { cli.stub(:upload) }
        let(:argv) { ['upload'] }
        it 'returns cwd' do
          cli.root.should == Dir.pwd
        end
      end
    end

    context 'with a command' do
      before { cli.stub(:upload) }
      let(:argv) { ['upload'] }

      before { cli.start }

      it 'saves it' do
        cli.command.should == 'upload'
      end
    end
  end
end
