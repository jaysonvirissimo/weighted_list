# frozen_string_literal: true

require 'weighted_list/version'
require 'weighted_list/sampler'

class WeightedList
  include Enumerable

  def initialize(hash)
    # TODO: Normalize weights to allow use of integers or floats
    @hash = hash
  end

  def each(&block)
    hash.keys.each(&block)
  end

  def sample(quantity = nil, random: Random)
    @random = random
    return single_item unless quantity
    (0...quantity).each_with_object(initial_memo) do |_index, memo|
      result = Sampler.new(memo[:current_list], random: random).call
      memo[:chosen].push(result.chosen)
      memo[:current_list] = result.remaining
    end[:chosen].compact
  end

  private

  attr_reader :hash, :random

  def initial_memo
    { chosen: [], current_list: hash }
  end

  def single_item
    Sampler.new(hash, random: random).call.chosen
  end
end
