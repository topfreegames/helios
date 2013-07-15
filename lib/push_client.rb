module Helios
  class PushClient

  	attr_accessor :options, :key, :secret
  	
  	def initialize(consumer_key, consumer_secret, options = {})
      @key    = consumer_key
      @secret = consumer_secret

      # ensure that keys are symbols
      # @options = @@default_options.merge(options.inject({}) { |options, (key, value)|
      #   options[key.to_sym] = value
      #   options
      # })
  		
  	end
  end
end