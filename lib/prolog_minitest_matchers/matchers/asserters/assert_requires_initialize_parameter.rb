# frozen_string_literal: true

module MiniTest
  # Adding custom assertions to make specs easier to read
  module Assertions
    # Actual test logic for `#assert_requires_initialize_parameter`.
    class AssertRequiresInitializeParameter
      def initialize(klass, full_params, param_key, message)
        @klass = klass
        @full_params = full_params
        @param_key = param_key
        @message = initial_message_from(message, param_key)
        self
      end

      def call(assert)
        assert.call(errors_as_expected(save_and_try_to_init), message)
      end

      private

      attr_reader :full_params, :klass, :message, :param_key

      def errors_as_expected(errors)
        errors[:expected]&.message == message
      end

      def initial_message_from(message, param_key)
        message || "missing keyword: #{param_key}"
      end

      def save_and_try_to_init
        verify_param_in_list
        saved_item = full_params[param_key]
        full_params.delete param_key
        errors = try_to_init
        full_params[param_key] = saved_item
        errors
      end

      def try_to_init
        expected_error = nil
        begin
          _ = klass.new full_params
        rescue ArgumentError => error
          expected_error = error
        rescue StandardError => error
          ap [:matcher_48, 'Unexpected error', error]
        end
        { expected: expected_error }
      end

      def verify_param_in_list
        no_param_message = "No key :#{param_key} in #{full_params}!"
        fail KeyError, no_param_message unless full_params.key?(param_key)
      end
    end # class MiniTest::Assertions::AssertRequiresInitializeParameter
  end
end
