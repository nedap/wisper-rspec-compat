require 'wisper'
require 'rspec/expectations'
require 'rspec/mocks/argument_list_matcher'

module Wisper
  module RSpec
    class EventRecorder
      include ::RSpec::Mocks::ArgumentMatchers
      attr_reader :broadcast_events

      def initialize
        @broadcast_events = []
      end

      def respond_to?(method_name)
        true
      end

      def respond_to_missing?(*)
        true
      end

      def method_missing(method_name, *args, **kwargs, &block)
        @broadcast_events << [method_name.to_s, *args, **kwargs]
      end

      def broadcast?(event_name, *args, **kwargs)

        expected_args = args.size > 0 ? args : [any_args]
        expected_kwargs = kwargs.empty? ? {} : kwargs
        @broadcast_events.any? do |event_params|
          name, *args, kwargs = event_params
          matcher = ::RSpec::Mocks::ArgumentListMatcher.new(event_name.to_s, *expected_args, **expected_kwargs)
          matcher.args_match?(name, *args, **kwargs)
        end
      end
    end

    module BroadcastMatcher
      class Matcher
        include ::RSpec::Matchers::Composable

        def initialize(event, *args, **kwargs)
          @event = event
          @args = args
          @kwargs = kwargs
        end

        def supports_block_expectations?
          true
        end

        def matches?(block)
          @event_recorder = EventRecorder.new

          Wisper.subscribe(@event_recorder, {}) do
            block.call
          end

          @event_recorder.broadcast?(@event, *@args, **@kwargs)
        end

        def description
          msg = "broadcast #{@event} event"
          msg += " with args: #{@args.inspect}" if @args.size > 0
          msg += " with kwargs: #{@kwargs.inspect}" unless @kwargs.empty?
          msg
        end

        def failure_message
          msg = "expected publisher to broadcast #{@event} event"
          msg += " with args: #{@args.inspect}" if @args.size > 0
          msg += " with args: #{@kwargs.inspect}" unless @kwargs.empty?
          msg << broadcast_events_list
          msg
        end

        def expected
          [] << @args
          [] << @kwargs
        end

        def actual
          broadcast_events_args
        end

        def diffable?
          true
        end

        def failure_message_when_negated
          msg = "expected publisher not to broadcast #{@event} event"
          msg += " with args: #{@args.inspect}" if @args.size > 0
          msg += " with args: #{@kwargs.inspect}" unless @kwargs.empty?
          msg
        end

        def broadcast_events_args
          @event_recorder.broadcast_events.map {|event| event.size == 1 ? [] : event[1..-1] }
        end

        def broadcast_events_list
          if @event_recorder.broadcast_events.any?
            " (actual events broadcast: #{event_names.join(', ')})"
          else
            " (no events broadcast)"
          end
        end
        private :broadcast_events_list

        def event_names
          @event_recorder.broadcast_events.map do |event|
            event.size == 1 ? event[0] : "#{event[0]}(#{event[1..-1].join(", ")})"
          end
        end
        private :event_names
      end

      def broadcast(event, *args, **kwargs)
        Matcher.new(event, *args, **kwargs)
      end

      alias_method :publish, :broadcast
    end
  end

  # Prior to being extracted from Wisper the matcher was namespaced as Rspec,
  # it is now RSpec. This will raise a helpful message for those upgrading to
  # Wisper 2.0
  module Rspec
    module BroadcastMatcher
      def self.included(base)
        raise 'Please include Wisper::RSpec::BroadcastMatcher instead of Wisper::Rspec::BroadcastMatcher (notice the capitalization of RSpec)'
      end
    end
  end
end

::RSpec::Matchers.define_negated_matcher :not_broadcast, :broadcast
::RSpec::Matchers.define_negated_matcher :not_publish, :publish
