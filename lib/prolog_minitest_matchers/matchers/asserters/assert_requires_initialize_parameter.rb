# frozen_string_literal: true

require_relative './base_assert_required_parameter'

module MiniTest
  # Adding custom assertions to make specs easier to read
  module Assertions
    # Actual test logic for `#assert_requires_initialize_parameter`.
    class AssertRequiresInitializeParameter < BaseAssertRequiredParameter
      private

      def default_message_for(param_key)
        "missing keyword: #{param_key}"
      end

      def error_class
        ArgumentError
      end

      def error_inducer
        -> { klass.new params }
      end
    end # class MiniTest::Assertions::AssertRequiresInitializeParameter
  end
end
