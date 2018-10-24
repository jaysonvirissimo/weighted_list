# frozen_string_literal: true

RSpec.describe WeightedList do
  it 'has a version number' do
    expect(WeightedList::VERSION).to be
  end

  describe '#sample' do
    context 'with an empty hash' do
      let(:item) { described_class.new(list).sample }
      let(:list) { {} }

      it { expect(item).to_not be }
    end

    context 'with a single entry hash' do
      let(:item) { described_class.new(list).sample }
      let(:list) { { thing: 1 } }

      it { expect(item).to eq(:thing) }
    end

    context 'for a list of time zones and their populations (in millions)' do
      let(:histogram) do
        (0..size).each_with_object(Hash.new(0)) do |_index, hash|
          outcome = described_class.new(list).sample
          hash[outcome] += 1
        end
      end
      let(:list) do
        { eastern: 150, central: 92, mountain: 21, pacific: 53 }.freeze
      end
      let(:precision) { 0.02 }
      let(:size) { 10_000 }

      it 'randomly selects zones in proportion to their percent of the total' do
        expect(histogram[:eastern].fdiv(size)).to be_within(precision).of(0.47)
        expect(histogram[:central].fdiv(size)).to be_within(precision).of(0.29)
        expect(histogram[:mountain].fdiv(size)).to be_within(precision).of(0.07)
        expect(histogram[:pacific].fdiv(size)).to be_within(precision).of(0.17)
      end
    end
  end
end
