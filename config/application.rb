require_relative "boot"

require "rails/all"

# require 'logstash-logger'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module App
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # LAGOON: We bypass all host authorization since this is both dynamic
    # and taken care of by the infrastructure.
    config.hosts = nil

    # LAGOON: Here we enable UDP logging if we're running in a Lagoon environment
    # This is demonstrated by using the `logstash-logger` Gem.
    # See https://docs.lagoon.sh/logging/logging/
    if ENV.has_key?('LAGOON_PROJECT') && ENV.has_key?('LAGOON_ENVIRONMENT') then
      lagoon_namespace = ENV['LAGOON_PROJECT'] + "-" + ENV['LAGOON_ENVIRONMENT']
      LogStashLogger.configure do |config|
        config.customize_event do |event|
          event["type"] = lagoon_namespace
        end
      end

      config.logstash.host = 'application-logs.lagoon.svc'
      config.logstash.type = :udp
      config.logstash.port = 5140
    end
    
  end
end
