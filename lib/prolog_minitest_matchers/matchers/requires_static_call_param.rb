# frozen_string_literal: true

require 'minitest/spec'

require_relative './asserters/assert_requires_static_call_param.rb'

module MiniTest
  # Adding custom assertions to make specs easier to read
  module Assertions
    def assert_requires_static_call_param(klass, full_params, param_key,
                                          message = nil)
      AssertRequiresStaticCallParam.new(klass, full_params, param_key, message)
                                   .call(method(:assert))
    end
  end

  # Make it available to MiniTest::Spec
  module Expectations
    infect_an_assertion :assert_requires_static_call_param,
                        :must_require_static_call_param, :reverse
  end
end # module MiniTest
