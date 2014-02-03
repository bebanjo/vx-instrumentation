require 'thread'

require File.expand_path("../instrumentation/version",           __FILE__)
require File.expand_path("../instrumentation/logger",            __FILE__)
require File.expand_path("../instrumentation/subscriber",        __FILE__)

require File.expand_path("../instrumentation/faraday",           __FILE__)
require File.expand_path("../instrumentation/active_record",     __FILE__)
require File.expand_path("../instrumentation/action_dispatch",   __FILE__)
require File.expand_path("../instrumentation/rails",             __FILE__)
require File.expand_path("../instrumentation/amqp_consumer",     __FILE__)
require File.expand_path("../instrumentation/worker",            __FILE__)

module Vx
  module Instrumentation

    DATE_FORMAT = '%Y-%m-%dT%H:%M:%S.%N%z'
    THREAD_KEY  = 'vx_instrumentation_keys'

    extend self

    def install(target, log_level = 0)
      Instrumentation::Logger.setup target
      Instrumentation::Logger.logger.level = log_level
      ObjectSpace.each_object(Class) do |c|
        next unless c.superclass == Instrumentation::Subscriber
        c.install
      end
    end

    def with(new_keys)
      old_keys = Thread.current[THREAD_KEY]
      begin
        Thread.current[THREAD_KEY] = (old_keys || {}).merge(new_keys)
        yield if block_given?
      ensure
        Thread.current[THREAD_KEY] = old_keys
      end
    end

    def default
      Thread.current[THREAD_KEY] || {}
    end

    def handle_exception(event, ex, env = {})
      tags = event.split(".")
      tags << "exception"
      tags.uniq!

      payload = {
        "@event"     => event,
        "@timestamp" => Time.now.strftime(DATE_FORMAT),
        "@tags"      => tags,
        "@fields"    => env,
        process_id:  Process.pid,
        thread_id:   Thread.current.object_id,
        exception:   ex.class.to_s,
        message:     ex.message.to_s,
        backtrace:   (ex.backtrace || []).map(&:to_s).join("\n"),
      }
      Vx::Instrumentation::Logger.logger.error(payload)
    end

    def delivery(name, payload, tags, started, finished)
      Vx::Instrumentation::Logger.logger.log(
        ::Logger::INFO,
        "@event"      => name,
        process_id:  Process.pid,
        thread_id:   Thread.current.object_id,
        "@timestamp"  => started.strftime(DATE_FORMAT),
        "@duration"   => (finished - started).to_f,
        "@fields"     => payload,
        "@tags"       => tags
      )
    end

  end

end
