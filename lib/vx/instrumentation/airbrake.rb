require 'airbrake'

Airbrake.configure do |config|
  if ENV['AIRBRAKE_API_KEY']
    $stdout.puts ' --> initializing Airbrake'

    config.api_key = ENV['AIRBRAKE_API_KEY']
    config.host    = ENV['AIRBRAKE_HOST']
    config.port    = ENV['AIRBRAKE_PORT'] || 80
    config.secure  = config.port == 443
  end
end

module Vx
  module Instrumentation
    module Airbrake

      def notify_airbrake(ex, env)
        ::Airbrake.notify ex, env
      end

    end
  end
end
