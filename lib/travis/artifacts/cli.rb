require 'optparse'

module Travis::Artifacts
  class Cli
    attr_reader :options, :argv, :paths
    attr_accessor :command, :client

    VALID_COMMANDS = ['upload', 'remove']

    def initialize(argv = nil)
      @argv    = argv || ARGV
      @options = { :paths => [], :private => false }
      @paths   = []
      @client  = Travis::Client.new
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
      Uploader.new(paths, options).upload
    end

    def remove
      Remover.new(options).remove
    end

    private

    def execute_command
      if VALID_COMMANDS.include? command
        send(command)
        return 0
      else
        STDERR.puts 'Could not find command'
        return 1
      end
    end

    def fetch_paths
      options[:paths]
    end

    def create_paths
      fetch_paths.each do |path|
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
          opt.banner = 'Usage: travis-artifacts COMMAND [OPTIONS]'
          opt.separator  ''
          opt.separator  'Commands'
          opt.separator  '     upload: upload files to server'
          opt.separator  '     remove: remove files from server'
          opt.separator  ''
          opt.separator  'Options'

          opt.on('--path PATH','path(s) to upload to (remove from) a server') do |path|
            options[:paths] << path
          end

          opt.on('--target-path TARGET_PATH', 'path to upload files to') do |target_path|
            options[:target_path] = target_path
          end

          opt.on('--clone-path CLONE_PATH', 'path to clone uploaded files to') do |clone_path|
            options[:clone_path] = clone_path
          end

          opt.on('--root ROOT', 'root directory for relative paths') do |root|
            options[:root] = root
          end

          opt.on('--mask', 'use mask for file to remove from a server') do |mask|
            options[:mask] = true
          end

          opt.on('--private', 'make artifacts non-public') do |root|
            options[:private] = true
          end

          opt.on('--cache-control CACHE_CONTROL_VALUE',
                 'set custom cache control metadata value') do |value|
            options[:cache_control] = value
          end

          opt.on('-h','--help','help') do
            puts @opt_parser
          end
        end
      end
    end
  end
end
