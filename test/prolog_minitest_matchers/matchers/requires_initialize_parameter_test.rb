# frozen_string_literal: true

require 'test_helper'

require 'prolog_minitest_matchers/matchers/requires_initialize_parameter'

describe 'must_require_initialize_parameter' do
  let(:subject_class) do
    Class.new do
      def initialize(foo:, bar:)
        # @foo = foo
        # @bar = bar
      end
    end # Class.new
  end
  let(:actual_error) do
    expect do
      expect(subject_class).must_require_initialize_parameter params, bad_key
    end
  end
  let(:bad_key) { :oops }
  let(:params) { { foo: :foo_param, bar: :bar_param } }

  describe 'passes when' do
    it 'a key in an initialisation hash is specified correctly' do
      expect(subject_class).must_require_initialize_parameter params, :foo
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
