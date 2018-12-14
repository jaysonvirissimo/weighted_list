# frozen_string_literal: true

require 'weighted_list/normalizer'
require 'weighted_list/version'
require 'weighted_list/sampler'

class WeightedList
  include Enumerable

  def self.[](collection)
    new(collection)
  end

  def initialize(collection)
    @hash = Normalizer.call(collection.clone)
  end

  def each(&block)
    hash.each_key(&block)
  end

  def sample(quantity = nil, random: Random, with_replacement: false)
    return select_item(hash, random: random).selected unless quantity
    quantity.times.each_with_object(initial_memo) do |_index, memo|
      result = select_item(memo[:current_list], random: random)
      return memo[:selected] if result.selected.nil?
      memo[:selected].push(result.selected)
      memo[:current_list] = (with_replacement ? hash : result.remaining)
    end[:selected]
  end

  def shuffle(random: Random)
    sample(hash.length, random: random)
  end

  private

  attr_reader :hash, :random

  def initial_memo
    { selected: [], current_list: hash }
  end

  def select_item(list, random:)
    Sampler.new(hash: list, random: random).call
  end
end
