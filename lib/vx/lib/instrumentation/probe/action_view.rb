require 'active_support/notifications'
require 'vx/instrumentation'

ActiveSupport::Notifications.subscribe(/\.action_view$/) do |event, started, finished, _, payload|
  if event[0] != "!"
    Vx::Lib::Instrumentation.delivery event, payload, event.split("."), started, finished
  end
end
