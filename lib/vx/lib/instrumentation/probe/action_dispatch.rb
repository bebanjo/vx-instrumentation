require 'active_support/notifications'

ActiveSupport::Notifications.subscribe(/\.action_dispatch$/) do |event, started, finished, _, payload|
  req = payload[:request]
  payload = {
    path:           req.fullpath,
    ip:             req.remote_ip,
    method:         req.method,
    referer:        req.referer,
    content_length: req.content_length,
    user_agent:     req.user_agent
  }
  Vx::Lib::Instrumentation.delivery event, payload, event.split("."), started, finished
end

