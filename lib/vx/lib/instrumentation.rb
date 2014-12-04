require 'thread'

require File.expand_path("../instrumentation/version",  __FILE__)
require File.expand_path("../instrumentation/logger",   __FILE__)
require File.expand_path("../instrumentation/stderr",   __FILE__)
require File.expand_path("../instrumentation/rack/handle_exceptions_middleware", __FILE__)

module Vx ; module Lib ; module Instrumentation

  extend Lib::Instrumentation::Stderr

  DATE_FORMAT = '%Y-%m-%dT%H:%M:%S.%N%z'
  THREAD_KEY  = 'vx_lib_instrumentation_keys'

  extend self

  def root
    File.expand_path("../", __FILE__)
  end

  def activate!
    Dir[root + "/*.rb"].each do |f|
      require f
    end
  end

  def install(target, log_level = 0)
    $stdout.puts " --> activate Vx::Instrumentation, log stored in #{target}"
    Lib::Instrumentation::Logger.setup target
    Lib::Instrumentation::Logger.logger.level = log_level

    activate!
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

    notify_stderr(ex)
    Lib::Instrumentation::Logger.logger.error(payload)
  end

  def delivery(name, payload, tags, started, finished)
    Lib::Instrumentation::Logger.logger.log(
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

end ; end ; end