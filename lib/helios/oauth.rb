require 'rack'
require 'helios/request'
require 'helios/oauth/constraint'

module Oauth
  class Application

    CONSTRAINTS_BY_TYPE = {
        :hosts        => [:only_hosts, :except_hosts],
        :path         => [:only, :except],
        :methods      => [:only_methods, :except_methods],
        :environments => [:only_environments, :except_environments]
    }

    def initialize(app, options={})
      default_options = {
      }
      CONSTRAINTS_BY_TYPE.values.each do |constraints|
        constraints.each { |constraint| default_options[constraint] = nil }
      end
      @app = app
      @options = default_options.merge(options)
    end

    def enforce_oauth?
      CONSTRAINTS_BY_TYPE.inject(true) do |memo, (type, keys)|
        memo && enforce_oauth_for?(keys)
      end
    end

    def enforce_oauth_for?(keys)
      provided_keys = keys.select { |key| @options[key] }
      if provided_keys.empty?
        true
      else
        provided_keys.all? do |key|
          rules = [@options[key]].flatten.compact
          rules.send([:except_hosts, :except_environments, :except].include?(key) ? :all? : :any?) do |rule|
            OAuthConstraint.new(key, rule, @request).matches?
          end
        end
      end
    end

    def call(env)
      @request = Rack::Request.new(env)
      return @app.call(env) if ignore?
      if enforce_oauth?
        @request = Oauth::Request.new(env)
        @request.with_valid_request do
          if client_verified?
            env["oauth_client"] = @client
            @app.call(env)
          else
            [401, {}, ["Unauthorized."]]
          end
        end
      else
        @app.call(env)
      end
    end

    private

    def ignore?
      if @options[:ignore]
        rules = [@options[:ignore]].flatten.compact
        rules.any? do |rule|
          OAuthConstraint.new(:ignore, rule, @request).matches?
        end
      else
        false
      end
    end

    def client_verified?
      @client = Helios::PushClient.new
      @request.verify_signature(@client)
    end
  end
end
