# frozen_string_literal: true

require 'test_helper'

require 'prolog_minitest_matchers/matchers/reports_failure_as'

describe 'must_report_failure_as' do
  let(:errors) { [error] }
  let(:error) { { foo: :bar } }

  CallResult = Struct.new(:failure?, :errors)

  it 'is true when a :failure? has the specified :errors Hash item' do
    call_result = CallResult.new true, errors
    expect(call_result).must_report_failure_as(error)
  end

  describe 'is false when the call_result does not' do
    it 'report :failure?' do
      call_result = CallResult.new false, []
      expect(call_result).wont_report_failure_as(error)
    end

    it 'include the specified error-hash item' do
      call_result = CallResult.new true, [{ other: :error }]
      expect(call_result).wont_report_failure_as(error)
    end
  end # describe 'is false when the call_result does not'

  describe 'reports the correct error message when' do
    it 'asserting a false value' do
      call_result = CallResult.new true, [{ other: :error }]
      actual = ''
      begin
        expect(call_result).must_report_failure_as(error)
      rescue MiniTest::Assertion => e
        actual = e.message
      end
      expected = 'Expected to find error with key foo and value bar; was ' \
        '[{:other=>:error}]'
      expect(actual).must_equal expected
    end

    it 'refuting a true value' do
      call_result = CallResult.new true, errors
      actual = ''
      begin
        expect(call_result).wont_report_failure_as(error)
      rescue MiniTest::Assertion => e
        actual = e.message
      end
      expected = 'Expected not to find error with key foo and value bar; was ' \
        '[{:foo=>:bar}]'
      expect(actual).must_equal expected
    end
  end # describe 'reports the correct error message when'
end
