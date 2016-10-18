# frozen_string_literal: true

require 'minitest/spec'

# require_relative './asserters/assert_requires_static_call_param.rb'

module MiniTest
  # Adding custom assertions to make specs easier to read
  module Assertions
    def assert_reports_failure_as(call_result, hash_pair, mesg_in = nil)
      as_expected = ARFAInternals.reports_failure_as(call_result, hash_pair)
      message = ARFAInternals.assert_message_for hash_pair, call_result, mesg_in
      assert as_expected, message
    end

    def refute_reports_failure_as(call_result, hash_pair, mesg_in = nil)
      as_expected = !ARFAInternals.reports_failure_as(call_result, hash_pair)
      message = ARFAInternals.refute_message_for hash_pair, call_result, mesg_in
      assert as_expected, message
    end

    # Stateless methods for `assert_report_failure_as` and refutation thereof.
    module ARFAInternals
      # Reek complains about :reek:ControlParameter` for `message`. Tough.
      def self.assert_message_for(hash_pair, call_result, message)
        message || _default_message_for(hash_pair, call_result, 'to find')
      end

      # Reek complains about :reek:ControlParameter` for `message`. Tough.
      def self.refute_message_for(hash_pair, call_result, message)
        message || _default_message_for(hash_pair, call_result, 'not to find')
      end

      def self.reports_failure_as(call_result, hash_pair)
        call_result.failure? && call_result.errors.include?(hash_pair)
      end

      def self._default_message_for(hash_pair, call_result, what)
        "Expected #{what} error with key #{hash_pair.keys.first} and " \
          "value #{hash_pair.values.first}; was #{call_result.errors}"
      end
    end
    private_constant :ARFAInternals
  end # module Assertions

  # Make it available to MiniTest::Spec
  module Expectations
    infect_an_assertion :assert_reports_failure_as, :must_report_failure_as,
                        true
    infect_an_assertion :refute_reports_failure_as, :wont_report_failure_as,
                        true
  end
end
