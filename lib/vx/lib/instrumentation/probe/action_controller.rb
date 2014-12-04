require 'active_support/notifications'

ActiveSupport::Notifications.subscribe(/\.action_controller$/) do |event, started, finished, _, payload|
  Vx::Lib::Instrumentation.delivery event, payload, event.split("."), started, finished
end

