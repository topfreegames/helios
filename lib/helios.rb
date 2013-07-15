require 'rack'
require 'helios/request'


module Helios
  class Application
    def initialize(app = nil, options = {}, &block)
      @app = Rack::Builder.new do
        map '/admin' do
          use Rack::Auth::Basic, "Restricted Area" do |username, password|
            username == (ENV['HELIOS_ADMIN_USERNAME'] || "") and password == (ENV['HELIOS_ADMIN_PASSWORD'] || "")
          end if ENV['HELIOS_ADMIN_USERNAME'] or ENV['HELIOS_ADMIN_PASSWORD']

          run Helios::Frontend.new
        end
        
        run Helios::Backend.new(&block)
      end
    end

    def call(env)
      @request = Helios::Request.new(env)

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
      @client = PushClient.new
      @request.verify_signature(@client)
    end

  end
end

require 'helios/backend'
require 'helios/frontend'
require 'helios/version'
