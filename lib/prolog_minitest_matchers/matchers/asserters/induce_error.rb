# frozen_string_literal: true

# Attempt to induce a specified failure, and report if successful or not.
class InduceError
  def self.call(error_class:, inducer:)
    InduceError.new(error_class, inducer).call
  end

  def call
    expected_error = nil
    begin
      inducer.call
    rescue error_class => error
      expected_error = error
    end
    { expected: expected_error }
  end

  protected

  def initialize(error_class, inducer)
    @error_class = error_class
    @inducer = inducer
    self
  end

  private

  attr_reader :error_class, :inducer
end # class InduceError
