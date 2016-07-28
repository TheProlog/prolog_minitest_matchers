# frozen_string_literal: true

require 'dry-types'

module MiniTest
  # Adding custom assertions to make specs easier to read
  module Assertions
    # Actual test logic for `#assert_requires_struct_attribute`.
    class AssertRequiresDryStructAttribute
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
        errors[:expected].message.match message
      end

      # Running Reek will complain about a :reek:ControlParameter. Protocol is.
      def initial_message_from(message, param_key)
        message || "] :#{param_key} is missing in Hash input"
      end

      def save_and_try_to_init
        verify_param_in_list
        filter_params_before { |params| try_to_init params }
      end

      def try_to_init(params)
        expected_error = nil
        begin
          klass.new params
        rescue Dry::Types::StructError => error
          expected_error = error
        end
        { expected: expected_error }
      end

      def verify_param_in_list
        raise KeyError, no_param_message unless param_in_full_list?
      end

      def no_param_message
        "No key :#{param_key} in #{full_params}!"
      end

      def param_in_full_list?
        full_params.key? param_key
      end

      def filter_params_before
        yield filtered_params
      end

      def filtered_params
        full_params.reject { |source_key, _| source_key == param_key }
      end
    end # class MiniTest::Assertions::AssertRequiresDryStructAttribute
  end
end
