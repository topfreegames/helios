
module Helios
  class PushOauthClient

  	@@default_options = {
      # Signature method used by server. Defaults to HMAC-SHA1
      :signature_method   => 'HMAC-SHA1',

      # default paths on site. These are the same as the defaults set up by the generators
      :request_token_path => '/oauth/request_token',
      :authorize_path     => '/oauth/authorize',
      :access_token_path  => '/oauth/access_token',

      :proxy              => nil,
      # How do we send the oauth values to the server see
      # http://oauth.net/core/1.0/#consumer_req_param for more info
      #
      # Possible values:
      #
      #   :header - via the Authorize header (Default) ( option 1. in spec)
      #   :body - url form encoded in body of POST request ( option 2. in spec)
      #   :query_string - via the query part of the url ( option 3. in spec)
      :scheme        => :header,

      # Default http method used for OAuth Token Requests (defaults to :post)
      :http_method   => :post,

      # Add a custom ca_file for consumer
      # :ca_file       => '/etc/certs.pem'

      # Add a custom ca_file for consumer
      # :ca_file       => '/etc/certs.pem'

      :oauth_version => "1.0"
    }

  	attr_accessor :options, :key, :secret

  	def initialize(options={})
      @key    = ENV['HELIOS_OAUTH_CONSUMER_KEY']
      @secret = ENV['HELIOS_OAUTH_CONSUMER_SECRET']

      # ensure that keys are symbols
      @options = @@default_options.merge(options.inject({}) { |options, (key, value)|
        options[key.to_sym] = value
        options
      })
  		
  	end
  end
end