require 'rack/auth/abstract/request'
require 'simple_oauth'

module Oauth
  class Request < Rack::Auth::AbstractRequest   
    def with_valid_request
      if provided? # #provided? defined in Rack::Auth::AbstractRequest
        if !oauth?
          [401, {}, ["Unauthorized. You forgot to include the Auth scheme"]]
        elsif params[:consumer_key].nil?
          [401, {}, ["Unauthorized. You forgot the consumer key"]]
        elsif params[:signature].nil?
          [401, {}, ["Unauthorized. You forgot to sign the request."]]
        elsif params[:signature_method].nil?
          [401, {}, ["Unauthorized. You forgot to include the OAuth signature method."]]
        else
          yield(request.env)
        end
      else
        [401, {}, ["Unauthorized."]]
      end
    end

    def verify_signature(client)
      return false unless client

      header = SimpleOAuth::Header.new(request.request_method, request.url, included_request_params, auth_header)
      header.valid?(:consumer_secret => client.secret)
    end

    def consumer_key
      params[:consumer_key]
    end

    private

    def params
      @params ||= SimpleOAuth::Header.parse(auth_header)
    end 

    # #scheme is defined as an instance method on Rack::Auth::AbstractRequest
    #
    def oauth?
      scheme.to_sym == :oauth
    end

    def auth_header
      @env[authorization_key]
    end

    # only include request params if Content-Type is set to application/x-www/form-urlencoded
    # (see http://tools.ietf.org/html/rfc5849#section-3.4.1)
    #
    def included_request_params
      request.content_type == "application/x-www-form-urlencoded" ? request.params : nil
    end
  end
end