module Vx
  module Instrumentation
    module Stderr

      def notify_stderr(e)
        backtrace = e.backtrace || []
        puts "#{backtrace.first}: #{e.message} (#{e.class})", backtrace.drop(1).map{|s| "\t#{s}"}
      end

    end

  end
end
