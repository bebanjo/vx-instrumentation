module Vx
  module Instrumentation
    class Worker < Subscriber

      event(/\.(worker|container)$/)

    end
  end
end
