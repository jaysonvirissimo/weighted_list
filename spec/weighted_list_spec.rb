# frozen_string_literal: true

RSpec.describe WeightedList do
  it 'has a version number' do
    expect(WeightedList::VERSION).to be
  end

  describe '#each' do
    let(:list) { { one: 1, two: 2, three: 3 } }
    let(:instance) { described_class.new(list) }

    it 'iterates over every list items' do
      array = []

      instance.each do |element|
        array.push(element)
      end

      expect(array.length).to eq(3)
    end
  end

  describe '#map' do
    let(:list) { { one: 1, two: 2, three: 3 } }
    let(:instance) { described_class.new(list) }

    it 'collects the result from each block' do
      string = instance.map(&:to_s).join(', ')

      expect(string).to match(/one, two, three/)
    end
  end

  describe '#sample' do
    context 'with an empty hash' do
      let(:item) { described_class.new(list).sample }
      let(:list) { {} }

      it { expect(item).to_not be }
    end

    context 'with a single entry hash' do
      let(:item) { described_class.new(list).sample }
      let(:list) { { thing: 10 } }

      it { expect(item).to eq(:thing) }

      context 'when given an alternative source of entropy' do
        let(:custom_klass) do
          class CustomRandomizer
            def rand; end
          end
          CustomRandomizer.new
        end
        let(:standard_klass) { Random }

        it 'should use that source of entropy' do
          allow(standard_klass).to receive(:rand)
          allow(custom_klass).to receive(:rand).and_return(1)
          described_class.new(list).sample(random: custom_klass)
          expect(standard_klass).to_not have_received(:rand)
          expect(custom_klass).to have_received(:rand)
        end
      end
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
