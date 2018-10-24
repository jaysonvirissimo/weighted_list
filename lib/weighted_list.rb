# frozen_string_literal: true

require 'weighted_list/version'

class WeightedList
  def initialize(hash)
    @hash = hash
  end

  def sample(random: Random)
    return if hash.empty?
    total_weight = hash.values.reduce(&:+)
    current_target = random.rand(total_weight)

    hash.each do |item, weight|
      return item if current_target <= weight
      current_target -= weight
    end
  end

  private

  attr_reader :hash
end
