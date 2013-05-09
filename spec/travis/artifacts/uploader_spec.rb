require 'spec_helper'

module Travis::Artifacts
  describe Uploader do
    let(:uploader) { Uploader.new(paths, {:target_path =>'artifacts/1'}) }
    let(:paths)    { [] }

    context 'without given target_path' do
      let(:uploader) { Uploader.new(paths) }

      it 'sets a default' do
        test = mock('test', :job_number => "10.1", :build_number => "10")
        Test.stub(:new => test)

        uploader.target_path.should == 'artifacts/10/10.1'
      end
    end

    describe '#upload_file' do
      it 'retries 3 times before giving up' do
        file = Artifact.new('source/file.png', 'destination/file.png')

        uploader.should_receive(:_upload).exactly(3).times.and_raise(StandardError)

        expect {
          uploader.upload_file(file)
        }.to raise_error(StandardError)
      end

      it 'simplifies excon error to not show request data' do
        file = Artifact.new('source/file.png', 'destination/file.png')

        request  = { :expects => 200 }
        response = mock('response', :status => 500)
        error_class = Class.new(Excon::Errors::HTTPStatusError)
        my_error = error_class.new('message', request, response)
        uploader.should_receive(:_upload).exactly(3).times.and_raise(my_error)

        expect {
          uploader.upload_file(file)
        }.to raise_error { |e|
          e.message.should == 'Expected(200) <=> Actual(500)'
        }
      end
    end

    describe '#upload' do
      let(:bucket) { mock('bucket') }
      let(:bucket_files) { mock('bucket_files') }

      before do
        files = [
          Artifact.new('source/path.png', 'destination/path.png')
        ]
        files[0].stub(:read => 'contents')
        uploader.stub(:files => files)

        uploader.stub(:bucket => bucket)
        bucket.stub(:files => bucket_files)
      end

      it 'uploads file to S3' do
        bucket_files.should_receive(:create).with({
          :key => 'artifacts/1/destination/path.png',
          :public => true,
          :body => 'contents',
          :content_type => 'image/png',
          :metadata => {'Cache-Control' => 'public, max-age=315360000'}

        })

        uploader.upload
      end

      context 'with private set to true' do
        let(:uploader) do
          Uploader.new(paths, {
            :target_path =>'artifacts/1',
            :private => true,
            :cache_control => 'public, but really ignored'
          })
        end

        it 'sets cache control metadata to private' do
          bucket_files.should_receive(:create).with({
            :key => 'artifacts/1/destination/path.png',
            :public => false,
            :body => 'contents',
            :content_type => 'image/png',
            :metadata => {'Cache-Control' => 'private'}

          })

          uploader.upload
        end
      end

      context 'with a custom cache control option' do
        let(:custom_cache_control) do
          [
            'private',
            'public, max-age=3600',
            'public',
          ].send(RUBY_VERSION > '1.8' ? :sample : :choice)
        end

        let(:uploader) do
          Uploader.new(paths, {
            :target_path =>'artifacts/1',
            :cache_control => custom_cache_control
          })
        end

        it 'uploads file to S3 with custom cache control header metadata' do
          files = [
            Artifact.new('source/path.png', 'destination/path.png')
          ]
          files[0].stub(:read => 'contents')
          uploader.stub(:files => files)

          bucket       = mock('bucket')
          bucket_files = mock('bucket_files')
          uploader.stub(:bucket => bucket)
          bucket.stub(:files => bucket_files)

          bucket_files.should_receive(:create).with({
            :key => 'artifacts/1/destination/path.png',
            :public => true,
            :body => 'contents',
            :content_type => 'image/png',
            :metadata => {'Cache-Control' => custom_cache_control}

          })

          uploader.upload
        end
      end
    end

    describe '#files' do
      let(:root)  { File.expand_path('../../../fixtures', __FILE__) }

      context 'with nested files from root' do
        let(:paths) { [Path.new('.', nil, root)] }

        it 'resolves paths into files to upload' do
          files = [
            'files/foo/bar/baz.txt',
            'files/logs/bar.log',
            'files/logs/foo.log',
            'files/output.txt'
          ]
          files.map! { |file| Artifact.new(File.join(root, '.', file), file) }

          uploader.files.sort_by { |o| o.source }.should == files.sort_by { |o| o.source }
        end
      end

      context 'with destination path and directory' do
        let(:paths) { [Path.new('files/logs', 'logs', root)] }

        it 'resolves paths into files to upload' do
          files = [
            'logs/bar.log',
            'logs/foo.log'
          ]
          files.map! { |file| Artifact.new(File.join(root, 'files', file), "#{file}") }

          uploader.files.sort_by { |o| o.source }.should == files.sort_by { |o| o.source }
        end
      end

      context 'with individual files' do
        let(:paths) {
          [Path.new('files/logs/bar.log', nil, root),
           Path.new('files/logs/foo.log', 'new/location/foo.log', root)]

        }

        it 'resolves paths into files to upload' do
          file1 = 'files/logs/bar.log'
          file2 = 'files/logs/foo.log'

          files = [
            Artifact.new(File.join(root, file1), 'files/logs/bar.log'),
            Artifact.new(File.join(root, file2), 'new/location/foo.log')
          ]

          uploader.files.should == files
        end
      end

      context 'with multilevel directory and to' do
        let(:paths) {
          [Path.new('files/foo', 'foo1', root)]
        }

        it 'resolves paths into files to upload' do
          uploader.files.should == [Artifact.new(File.join(root, 'files/foo/bar/baz.txt'), 'foo1/bar/baz.txt')]
        end
      end
    end
  end
end
