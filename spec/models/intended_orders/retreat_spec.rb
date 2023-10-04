# frozen_string_literal: true

describe IntendedOrders::Build, variant: :classic do
  let(:turn) { build(:turn) }
  let(:orders) { {} }
  let(:ios) { Entities::IntendedOrders.new(orders) }

  describe '#validate!' do
    subject { orders.each_value { |o| o.validate!(orders: ios) } }

    let(:ven_unit_position) { build(:unit_position, :army, turn:, territory: t_ven, country: country_ita) }
    let(:orders) do
      {
        ven: build(:intended_order, :retreat, unit_position: ven_unit_position, turn:, to_territory: t_pie)
      }
    end
    let(:order) { orders[:ven] }

    it 'succeeds' do
      # TODO: implement retreats
      subject
      expect(order).to be_successful
    end
  end
end
