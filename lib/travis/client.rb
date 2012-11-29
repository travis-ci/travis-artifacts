require 'faraday'
require 'faraday_middleware'

module Travis
  class Client
    attr_reader :connection

    def initialize
      @connection = create_connection
    end

    # TODO: this needs to be fixed before going too far, returning body without
    #       ability to inspect response or returning nil on any failure are not
    #       the best ways to deal with API client
    def fetch_config(job_id)
      response = get("/jobs/#{job_id}")
      if (200..299).include?(response.status)
        response.body['job']['config']
      else
        # TODO: I should probably raise here
        nil
      end
    end

    private

    http_methods = [:get, :post, :put, :patch, :delete, :head]
    http_methods.each do |method|

      define_method(method) do |*args, &block|
        path, params, headers = *args
        connection.send(method, path, params, headers, &block)
      end
    end

    def create_connection
      # TODO: support for pro
      Faraday.new(:url => 'https://api.travis-ci.org') do |faraday|
        faraday.response :json, :content_type => /\bjson$/

        faraday.adapter :net_http
      end.tap do |connection|
        connection.headers['Accept'] = 'application/vnd.travis-ci.2+json'
      end
    end
  end
end
