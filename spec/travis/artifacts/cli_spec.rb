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
      let(:argv) do
        ['upload', '--path', 'foo', '--target-path', 'bar', '--cache-control', 'public, max-age=3600']
      end

      it 'calls Uploader with given paths, target_path, and cache_control' do
        uploader = mock('uploader')
        Uploader.should_receive(:new).with([Path.new('foo', nil, Dir.pwd)], \
                                          {:paths=>["foo"], :private=>false, :target_path=>"bar",
                                           :cache_control=>'public, max-age=3600'}\
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

    context 'with a valid command' do
      let(:argv) { ['upload'] }
      let(:retcode) { cli.start }
      before { cli.stub(:upload) }

      it 'returns 0' do
        retcode.should == 0
      end
    end

    context 'with an invalid command' do
      let(:argv) { ['derf'] }
      let(:retcode) { cli.start }

      it 'returns 1' do
        STDERR.stub(:puts)
        retcode.should == 1
      end

      it 'tells us about it' do
        STDERR.should_receive(:puts).with(/Could not find command/)
        cli.start
      end
    end

    context 'with an internal error' do
      let(:argv) { ['upload'] }
      let(:custom_error) { Class.new(Exception) }
      before { cli.stub(:upload) { raise custom_error } }

      it 'allows it to bubble up' do
        expect { cli.start }.to raise_error(custom_error)
      end
    end
  end
end
