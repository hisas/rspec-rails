require 'rspec/core/deprecation'
require 'rspec/core/backward_compatibility'
require 'rspec/matchers'

begin
  require 'test/unit/assertionfailederror'
rescue LoadError
  module Test
    module Unit
      class AssertionFailedError < StandardError
      end
    end
  end
end

begin
  require "action_controller"
rescue LoadError
end

module RSpec::Rails
  module RoutingSpecMatchers
    extend RSpec::Matchers::DSL

    matcher :route_to do |route_options|
      match_unless_raises Test::Unit::AssertionFailedError do |path|
        assertion_path = { :method => path.keys.first, :path => path.values.first }
        assert_routing(assertion_path, route_options)
      end

      failure_message_for_should do
        rescued_exception.message
      end
    end

    matcher :be_routable do
      match_unless_raises ActionController::RoutingError do |path|
        @routing_options = routes.recognize_path(
          path.values.first, :method => path.keys.first
        )
      end

      failure_message_for_should_not do |path|
        "expected #{path.inspect} not to be routable, but it routes to #{@routing_options.inspect}"
      end
    end
  end
end
