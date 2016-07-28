# frozen_string_literal: true

require_relative './induce_error'
require_relative './verify_key_in_hash'

module MiniTest
  # Adding custom assertions to make specs easier to read
  module Assertions
    # Base assertion class to verify error raised when parameter omitted.
    class BaseAssertRequiredParameter
      def initialize(klass, params, param_key, message)
        message ||= default_message_for(param_key)
        @params = Internals.hash_without_key(params, param_key)
        @klass = klass
        @param_key = param_key
        @message = message
        self
      end

      def call(assert)
        assert.call(correct_error_message_for?(errors), message)
      end

      private

      attr_reader :params, :klass, :message, :param_key

      def correct_error_message_for?(errors)
        errors[:expected]&.message == message
      end

      def errors
        InduceError.call error_class: error_class, inducer: error_inducer
      end

      # Methods that neither affect nor are affected by instance state.
      module Internals
        def self.hash_without_key(hash, key)
          VerifyKeyInHash.call hash, key
          hash.dup.reject { |source_key, _| source_key == key }
        end
      end
      private_constant :Internals
    end # class MiniTest::Assertions::BaseAssertRequiredParameter
  end
end
