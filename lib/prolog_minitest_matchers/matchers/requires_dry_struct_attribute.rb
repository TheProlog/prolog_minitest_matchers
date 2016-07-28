# frozen_string_literal: true

require_relative './asserters/assert_requires_dry_struct_attribute'

module MiniTest
  # Adding custom assertions to make specs easier to read
  module Assertions
    def assert_requires_dry_struct_attribute(klass, full_params, param_key,
                                             message = nil)
      AssertRequiresDryStructAttribute.new(klass, full_params, param_key,
                                           message).call(method(:assert))
    end
  end

  # Make it available to MiniTest::Spec
  module Expectations
    infect_an_assertion :assert_requires_dry_struct_attribute,
                        :must_require_dry_struct_attribute, :reverse
  end
end
