require 'rack/push-notification'

require 'sinatra/base'
require 'sinatra/param'

require 'houston'

require 'net/http'

class Helios::Backend::PublicPushNotification < Sinatra::Base
  helpers Sinatra::Param
  attr_reader :apn_certificate, :apn_environment

  def initialize(app, options = {}, &block)
    super(Rack::PushNotification.new)

    @apn_certificate = options[:apn_certificate] || ENV['APN_CERTIFICATE']
    @apn_environment = options[:apn_environment] || ENV['APN_ENVIRONMENT']
  end

  before do
    content_type :json
  end


  get '/devices/:token/?' do
    record = ::Rack::PushNotification::Device.find(token: params[:token])

    if record
      {device: record}.to_json
    else
      status 404
    end
  end

  private

  def client
    begin
      return nil unless apn_certificate and ::File.exist?(apn_certificate)

      client = case apn_environment.to_sym
               when :development
                 Houston::Client.development
               when :production
                 Houston::Client.production
               end

      client.certificate = ::File.read(apn_certificate)

      return client
    rescue
      return nil
    end
  end
end
