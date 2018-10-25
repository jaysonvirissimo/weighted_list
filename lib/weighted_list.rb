# frozen_string_literal: true

require 'weighted_list/version'
require 'weighted_list/sampler'

class WeightedList
  include Enumerable

  def initialize(hash)
    @hash = hash
  end

  def each(&block)
    hash.keys.each(&block)
  end

  def sample(quantity = nil, random: Random)
    return if hash.empty?
    return Sampler.new(hash, random: random).call.chosen unless quantity
  end

  private

  attr_reader :hash
end
