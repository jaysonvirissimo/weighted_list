# frozen_string_literal: true

class WeightedList
  class Sampler
    def initialize(hash, random: Random)
      @hash = hash.clone
      @random = random
    end

    def call
      Result.new(chosen, remaining)
    end

    private

    attr_reader :hash, :random

    Result = Struct.new(:chosen, :remaining)

    def choose
      return if hash.empty?
      current_target = random.rand(total_weight)

      hash.each do |item, weight|
        return item if current_target <= weight
        current_target -= weight
      end
    end

    def chosen
      @chosen ||= choose
    end

    def remaining
      hash.reject { |item, _weight| chosen == item }
    end

    def total_weight
      @total_weight ||= hash.values.reduce(&:+)
    end
  end
end
