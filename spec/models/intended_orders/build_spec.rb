# frozen_string_literal: true

describe IntendedOrders::Build, variant: :classic do
  let(:turn) { build(:turn) }
  let(:orders) { {} }
  let(:ios) { Entities::IntendedOrders.new(orders) }

  describe '#validate!' do
    subject { orders.each_value { |o| o.validate!(orders: ios) } }

    let(:orders) do
      {
        ven: build(:intended_order, :build, turn:, from_territory: t_ven)
      }
    end
    let(:order) { orders[:ven] }

    it 'succeeds' do
      # TODO: implement builds
      subject
      expect(order).to be_successful
    end
  end
end
