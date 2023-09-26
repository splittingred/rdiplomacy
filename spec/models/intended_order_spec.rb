# frozen_string_literal: true

describe IntendedOrder do
  let(:io_attributes) { {} }
  let(:io) { build(:intended_order, **io_attributes) }

  describe '#move?' do
    subject { io.move? }

    context 'when a move order' do
      let(:io_attributes) { super().merge(move_type: Order::TYPE_MOVE) }

      it 'returns true' do
        expect(subject).to be_truthy
      end
    end

    context 'when not a move order' do
      let(:io_attributes) { super().merge(move_type: Order::TYPE_HOLD) }

      it 'returns false' do
        expect(subject).to be_falsey
      end
    end
  end

  describe '#hold?' do
    subject { io.hold? }

    context 'when a hold order' do
      let(:io_attributes) { super().merge(move_type: Order::TYPE_HOLD) }

      it 'returns true' do
        expect(subject).to be_truthy
      end
    end

    context 'when not a hold order' do
      let(:io_attributes) { super().merge(move_type: Order::TYPE_MOVE) }

      it 'returns false' do
        expect(subject).to be_falsey
      end
    end
  end
end
