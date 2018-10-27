# frozen_string_literal: true

class WeightedList
  class Sampler
    def initialize(hash:, random:)
      @hash = hash
      @random = random
    end

    def call
      Result.new(selected, remaining)
    end

    private

    attr_reader :hash, :random

    Result = Struct.new(:selected, :remaining)

    def select
      return if hash.empty?
      current_target = random.rand(total_weight)

      hash.each do |item, weight|
        return item if current_target <= weight
        current_target -= weight
      end
    end

    def selected
      @selected ||= select
    end

    def remaining
      hash.reject { |item, _weight| selected == item }
    end

    def total_weight
      @total_weight ||= hash.values.reduce(&:+)
    end
  end
end
