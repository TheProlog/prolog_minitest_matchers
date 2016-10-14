# frozen_string_literal: true

require 'dry-struct'

require_relative './base_assert_required_parameter'

module MiniTest
  # Adding custom assertions to make specs easier to read
  module Assertions
    # Actual test logic for `#assert_requires_struct_attribute`.
    class AssertRequiresDryStructAttribute < BaseAssertRequiredParameter
      private

      def default_message_for(param_key)
        "] :#{param_key} is missing in Hash input"
      end

      def error_class
        Dry::Struct::Error
      end

      def error_inducer
        -> { klass.new params }
      end
    end # class MiniTest::Assertions::AssertRequiresDryStructAttribute
  end
end
