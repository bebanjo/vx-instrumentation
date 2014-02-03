module Vx
  module Instrumentation
    class Worker < Subscriber

      event(/\.worker$/)

    end
  end
end
