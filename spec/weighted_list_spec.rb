# frozen_string_literal: true

RSpec.describe WeightedList do
  it 'has a version number' do
    expect(WeightedList::VERSION).to be
  end

  describe '#sample' do
    context 'for a list of time zones and their populations (in millions)' do
      let(:histogram) do
        (0..size).each_with_object(Hash.new(0)) do |_index, hash|
          hash[described_class.new(list).sample] += 1
        end
      end
      let(:list) do
        { 'Eastern': 150, 'Central': 92, 'Mountain': 21, 'Pacific': 53 }.freeze
      end
      let(:precision) { 2 }
      let(:size) { 1000 }

      it 'randomly selects zones in proportion to their percent of the total' do
        expect(histogram['Eastern'] / size).to be_within(precision).of(47)
        expect(histogram['Central'] / size).to be_within(precision).of(29)
        expect(histogram['Mountain'] / size).to be_within(precision).of(7)
        expect(histogram['Pacific'] / size).to be_within(precision).of(17)
      end
    end
  end
end
