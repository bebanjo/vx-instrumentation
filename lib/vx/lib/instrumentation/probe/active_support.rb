require 'active_support/notifications'

ActiveSupport::Notifications.subscribe(/\.active_support$/) do |event, started, finished, _, payload|
  Vx::Lib::Instrumentation.delivery event, payload, event.split("."), started, finished
end

