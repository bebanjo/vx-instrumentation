require 'json'
require 'logger'
require 'active_support/core_ext/hash/deep_merge'

module Vx

  module Instrumentation

    class Logger

      def initialize(device)
        @device = device
      end

      def method_missing(sym, *args, &block)
        if @device.respond_to?(sym)
          begin
            @device.send(sym, *args, &block)
          rescue Exception => e
            $stderr.puts "#{e.class.to_s}, #{e.message.inspect} [#{sym.inspect} #{args.inspect}]"
            $stderr.puts e.backtrace.map{|b| "\t#{b}" }.join("\n")
          end
        else
          super
        end
      end

      def respond_to?(sym)
        @device.respond_to?(sym)
      end

      class << self
        attr_accessor :logger

        def setup(target)
          log = ::Logger.new(target)
          log.formatter = Formatter
          @logger = new(log)
        end
      end

      class Formatter

        def self.safe_value(value, options = {})
          case value.class.to_s
          when "String", "Fixnum", "Float"
            value
          when "Symbol", "BigDecimal"
            value.to_s
          when "Array"
            value = value.map(&:to_s)
            options[:join_arrays] ? value.join("\n") : value
          when 'NilClass'
            nil
          else
            value.inspect
          end
        end

        def self.make_safe_hash(msg, options = {})
          msg.inject({}) do |acc, pair|
            msg_key, msg_value = pair

            if msg_key == "@fields"
              acc[msg_key] = make_safe_hash(msg_value, join_arrays: true)
            else
              acc[msg_key] = safe_value(msg_value, options)
            end
            acc
          end
        end

        def self.call(severity, _, _, msg)
          values = Vx::Instrumentation.default.dup

          case
          when msg.is_a?(Hash)
            values.deep_merge! msg
          when msg.respond_to?(:to_h)
            values.merge! msg.to_h
          else
            values.deep_merge!(message: msg)
          end

          values.deep_merge!(severity: severity.to_s.downcase)

          values = make_safe_hash(values)

          ::JSON.dump(values) + "\n"
        end

      end

    end

  end
end
