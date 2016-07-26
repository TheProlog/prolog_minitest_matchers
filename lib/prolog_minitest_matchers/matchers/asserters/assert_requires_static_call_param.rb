# frozen_string_literal: true

module MiniTest
  # Adding custom assertions to make specs easier to read
  module Assertions
    # Actual test logic for `#assert_requires_static_call_paramr`.
    class AssertRequiresStaticCallParam
      def initialize(klass, full_params, param_key, message)
        @klass = klass
        @full_params = full_params
        @param_key = param_key
        @message = initial_message_from(message, param_key)
        self
      end

      def call(assert)
        verify_param_in_list(assert)
        assert.call(errors_as_expected(save_and_try_to_call), message)
      end

      private

      attr_reader :full_params, :klass, :message, :param_key

      def errors_as_expected(errors)
        errors[:expected]&.message == message
      end

      def filtered_params
        full_params.dup.reject { |source_key, _| source_key == param_key }
      end

      # Running Reek will complain about a :reek:ControlParameter. Protocol is.
      def initial_message_from(message, param_key)
        message || "missing keyword: #{param_key}"
      end

      def key_not_found_message
        "Key :#{param_key} not found in #{full_params}!"
      end

      def save_and_try_to_call
        save_and_delete_param_before { |params| try_to_call params }
        # saved_item = full_params[param_key]
        # full_params.delete param_key
        # errors = try_to_call
        # full_params[param_key] = saved_item
        # errors
      end

      def try_to_call(params)
        expected_error = nil
        begin
          klass.call params
        rescue ArgumentError => error
          expected_error = error
        end
        { expected: expected_error }
      end

      def save_and_delete_param_before
        yield filtered_params
      end

      def verify_param_in_list(assert)
        assert.call(param_in_list?, key_not_found_message)
      end

      def param_in_list?
        full_params.key?(param_key)
      end
    end # class MiniTest::Assertions::AssertRequiresStaticCallParam
  end
end
