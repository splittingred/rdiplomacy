# frozen_string_literal: true

describe IntendedOrders::Hold, variant: :classic do
  let(:turn) { build :turn }
  let(:orders) { {} }
  let(:ios) { Entities::IntendedOrders.new(orders) }

  describe '#validate!' do
    subject { order.validate!(orders: ios) }

    let(:ven_unit_position) { build(:unit_position, turn:, territory: t_ven, country: country_ita) }
    let(:orders) do
      {
        # F VEN H
        ven: build(:intended_order, :hold, unit_position: ven_unit_position)
      }
    end
    let(:order) { orders[:ven] }

    context 'when unit is not already dislodged' do
      it 'succeeds the order' do
        subject
        expect(order).to be_successful
      end
    end

    context 'when unit is already dislodged' do
      let(:ven_unit_position) { build(:unit_position, :dislodged, turn:, territory: t_ven, country: country_ita) }

      it 'fails the order' do
        subject
        expect(order).to be_failed
      end
    end
  end
end
