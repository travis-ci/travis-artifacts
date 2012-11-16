require 'optparse'

module Travis::Artifacts
  class Cli
    attr_reader :options, :argv, :paths
    attr_accessor :command

    VALID_COMMANDS = ['upload']

    def initialize(argv = nil)
      @argv    = argv || ARGV
      @options = { :paths => [] }
      @paths   = []
    end

    # I would like to use option parser for now, to keep
    # the code super simple and without too much external
    # dependencies, if it grows too much, I may change it
    def start
      parse!
      create_paths

      execute_command
    end

    def root
      options[:root] || Dir.pwd
    end

    def upload
      Uploader.new(paths, job_id).upload
    end

    private

    def job_id
      options[:job_id]
    end

    def execute_command
      if VALID_COMMANDS.include? command
        send(command)
      else
        STDERR.puts 'Could not find command'
        exit 1
      end
    end

    def create_paths
      options[:paths].each do |path|
        from, to = path.split(':')
        paths << Path.new(from, to, root)
      end
    end

    def parse!
      self.command = argv[0]
      parser.parse! argv
    end

    def parser
      @opt_parser ||= begin
        options = self.options

        OptionParser.new do |opt|
          opt.banner = 'Usage: travis-uploader COMMAND [OPTIONS]'
          opt.separator  ''
          opt.separator  'Commands'
          opt.separator  '     upload: upload files to server'
          opt.separator  ''
          opt.separator  'Options'

          opt.on('--path PATH','path(s) to upload to a server') do |path|
            options[:paths] << path
          end

          opt.on('-j', '--job-id JOB_ID', 'id of the current job') do |job_id|
            options[:job_id] = job_id
          end

          opt.on('--root ROOT', 'root directory for relative paths') do |root|
            options[:root] = root
          end

          opt.on('-h','--help','help') do
            puts @opt_parser
          end
        end
      end
    end
  end
end
