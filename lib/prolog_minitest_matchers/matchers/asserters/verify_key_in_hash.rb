# frozen_string_literal: true

# Used to validate incoming parameter hash.
class VerifyKeyInHash
  def self.call(hash, key)
    VerifyKeyInHash.new(hash, key).call
  end

  def call
    raise KeyError, no_key_message unless key_in_hash?
  end

  protected

  def initialize(hash, key)
    @hash = hash
    @key = key
    self
  end

  private

  attr_reader :hash, :key

  def key_in_hash?
    hash.key? key
  end

  def no_key_message
    "No key :#{key} in #{hash}!"
  end
end # class VerifyKeyInHash
