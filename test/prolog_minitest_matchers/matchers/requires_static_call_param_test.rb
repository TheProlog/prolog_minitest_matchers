# frozen_string_literal: true

require 'test_helper'

require 'prolog_minitest_matchers/matchers/requires_static_call_param'

describe 'must_require_static_call_param' do
  let(:subject_class) do
    Class.new do
      def self.call(foo:, bar:) # rubocop:disable Lint/UnusedMethodArgument
        # @foo = foo
        # @bar = bar
        # self
      end
    end # Class.new
  end
  let(:actual_error) do
    expect do
      expect(subject_class).must_require_static_call_param params, bad_key
    end
  end
  let(:bad_key) { :oops }
  let(:params) { { foo: :foo_param, bar: :bar_param } }

  describe 'passes when' do
    it 'a key in a .call parameter Hash is specified correctly' do
      expect(subject_class).must_require_static_call_param params, :foo
    end
  end # 'passes when'

  describe 'fails when' do
    describe 'an incorrect parameter is specified, and' do
      let(:subject_error) { actual_error.must_raise KeyError }

      it 'raises a KeyError' do
        actual_error.must_raise KeyError
      end

      it 'has the correct error message' do
        expected = "No key :#{bad_key} in #{params.inspect}!"
        expect(subject_error.message).must_equal expected
      end
    end # describe 'an incorrect parameter is specified, and'
  end # describe 'fails when'
end
