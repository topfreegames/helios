require 'rack'
require 'helios/request'


module Oauth
  class Application
    def initialize(app)
      @app = app
    end

    def call(env)
      @request = Oauth::Request.new(env)

      @request.with_valid_request do
        if client_verified?
          env["oauth_client"] = @client
          @app.call(env)
        else
          [401, {}, ["Unauthorized."]]
        end
      end
    end

    private

    def client_verified?
      @client = Helios::PushClient.new
      @request.verify_signature(@client)
    end

  end
end
