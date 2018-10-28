# frozen_string_literal: true

class WeightedList
  class Normalizer
    def self.call(collection)
      new(collection).call
    end

    def initialize(collection)
      @hash = collection.to_h
    end

    def call
      hash.each_with_object({}) do |(item, weight), normalized_hash|
        normalized_hash[item] = weight.fdiv(total_weight)
      end
    end

    private

    attr_reader :hash

    def total_weight
      @total_weight ||= hash.values.reduce(&:+)
    end
  end
end
