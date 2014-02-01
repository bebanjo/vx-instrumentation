require 'logger'
require 'active_support/notifications'

module Vx
  module Instrumentation
    Subscriber = Struct.new(:name, :payload, :tags) do

      def process ; end

      class << self

        def install
          ev = event || /.*/
          $stdout.puts " --> add instrumentation #{self.to_s} to #{ev.inspect}"
          ActiveSupport::Notifications.subscribe(ev) do |name, started, finished, uid, payload|
            if name[0] != '!'
              tags = name.split(".")
              inst = new(name, payload, tags).tap(&:process)
              Instrumentation.delivery(inst.name, inst.payload, inst.tags.uniq, started, finished)
            end
          end
        end

        def event(name = nil)
          @event = name if  name
          @event
        end

      end

    end
  end
end
