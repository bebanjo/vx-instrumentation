require 'pp'

module Vx
  module Instrumentation
    class ActionDispatch < Subscriber

      event(/\.action_dispatch$/)

      def process
        req = payload.delete(:request)
        self.payload = {
          path:           req.fullpath,
          ip:             req.remote_ip,
          method:         req.method,
          referer:        req.referer,
          content_length: req.content_length,
          user_agent:     req.user_agent
        }
      end

    end
  end
end
