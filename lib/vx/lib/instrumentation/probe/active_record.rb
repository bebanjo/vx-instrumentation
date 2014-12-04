require 'active_support/notifications'

ActiveSupport::Notifications.subscribe(/\.active_record$/) do |event, started, finished, _, payload|

  binds =
    (payload[:binds] || []).map do |column, value|
      if column
        if column.binary?
          value = "<#{value.bytesize} bytes of binary data>"
        end
        [column.name, value]
      else
        [nil, value]
      end
    end.inspect

  payload = {
    sql:      payload[:sql],
    binds:    binds,
    name:     payload[:name],
    duration: payload[:duration]
  }

  Vx::Lib::Instrumentation.delivery event, payload, event.split("."), started, finished
end

