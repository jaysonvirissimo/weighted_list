# frozen_string_literal: true

RSpec.describe WeightedList do
  let(:collection) { { one: 1, two: 2, three: 3 } }

  it 'has a version number' do
    expect(WeightedList::VERSION).to be
  end

  describe '.[]' do
    let(:instance) { described_class[collection] }

    it 'returns an instance' do
      expect(instance).to respond_to(:each)
      expect(instance).to respond_to(:map)
      expect(instance).to respond_to(:sample)
    end
  end

  describe '#each' do
    let(:instance) { described_class.new(collection) }

    it 'iterates over list items' do
      array = []

      instance.each do |element|
        array.push(element)
      end

      expect(array.length).to eq(3)
    end
  end

  describe '#map' do
    let(:instance) { described_class.new(collection) }

    it 'collects the result from each block' do
      string = instance.map(&:to_s).join(', ')

      expect(string).to match(/one, two, three/)
    end
  end

  describe '#sample' do
    context 'without replacement' do
      context 'without specifying a quantity' do
        context 'with an empty array' do
          let(:item) { described_class.new(collection).sample }
          let(:collection) { [] }

          it { expect(item).to_not be }
        end

        context 'with an empty hash' do
          let(:item) { described_class.new(collection).sample }
          let(:collection) { {} }

          it { expect(item).to_not be }
        end

        context 'with a single entry 2D array' do
          let(:item) { described_class.new(collection).sample }
          let(:collection) { [[:thing, 10]] }

          it { expect(item).to eq(:thing) }
        end

        context 'with a single entry hash' do
          let(:item) { described_class.new(collection).sample }
          let(:collection) { { thing: 10 } }

          it { expect(item).to eq(:thing) }

          it 'does not mutate the user-given hash' do
            original_collection = collection.dup
            item
            expect(collection).to eq(original_collection)
          end

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
              described_class.new(collection).sample(random: custom_klass)
              expect(standard_klass).to_not have_received(:rand)
              expect(custom_klass).to have_received(:rand)
            end
          end
        end

        context 'for a list of time zones and their populations (in millions)' do
          let(:histogram) do
            (0..size).each_with_object(Hash.new(0)) do |_index, hash|
              outcome = described_class.new(collection).sample
              hash[outcome] += 1
            end
          end
          let(:collection) do
            { eastern: 150, central: 92, mountain: 21, pacific: 53 }.freeze
          end
          let(:precision) { 0.01 }
          let(:size) { 100_000 }

          it 'randomly selects zones in proportion to their percent of the total' do
            expect(histogram[:eastern].fdiv(size)).to be_within(precision).of(0.474)
            expect(histogram[:central].fdiv(size)).to be_within(precision).of(0.291)
            expect(histogram[:mountain].fdiv(size)).to be_within(precision).of(0.066)
            expect(histogram[:pacific].fdiv(size)).to be_within(precision).of(0.168)
          end
        end
      end

      context 'with a specified quantity' do
        let(:instance) { described_class.new(collection) }

        context 'of zero' do
          let(:quantity) { 0 }

          it 'should return an empty collection' do
            expect(instance.sample(quantity)).to be_empty
          end
        end

        context 'of one' do
          let(:quantity) { 1 }

          it 'should return a collection' do
            expect(instance.sample(quantity)).to respond_to(:length)
          end
        end

        context 'of several' do
          let(:quantity) { 3 }

          it 'should return the number of items requested' do
            expect(instance.sample(quantity).length).to eq(quantity)
          end

          it 'should not return any repeats' do
            selected = instance.sample(quantity)
            expect(selected.length).to eq(selected.uniq.length)
          end

          it 'should return only as many non-repeating items as are available' do
            selected = instance.sample(quantity + 10)
            expect(selected.length).to eq(collection.length)
            expect(selected).to_not include(nil)
          end
        end
      end
    end

    context 'with replacement' do
      let(:collection) { { a: 99, b: 1, c: 1, d: 1, e: 1 } }
      let(:instance) { described_class.new(collection) }

      it 'allows repeated values' do
        selected = instance.sample(5, with_replacement: true)
        expect(selected.uniq.length).to_not eq(selected.length)
      end
    end
  end

  describe '#shuffle' do
    let(:instance) { described_class.new(collection) }
    let(:shuffled) { instance.shuffle }

    it { expect(instance).to respond_to(:shuffle) }

    it 'returns everything in the original collection' do
      collection.each do |item, weight|
        expect(shuffled).to include(item)
      end
    end

    it 'returns nothing that is not in the original collection' do
      shuffled.each do |item|
        expect(collection).to include(item)
      end
    end

    context 'for an empty collection' do
      let(:collection) { {} }

      it { expect(instance.shuffle).to be_empty }
    end
  end

  describe '#sort' do
    let(:collection) { { a: 10, c: 100, d: 200, b: 1 } }
    let(:instance) { described_class.new(collection) }

    it 'orders the list items' do
      expect(instance.sort).to match(%i[a b c d])
    end
  end
end
