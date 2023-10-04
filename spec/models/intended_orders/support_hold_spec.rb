# frozen_string_literal: true

describe IntendedOrders::SupportHold, variant: :classic do
  let(:turn) { build(:turn) }
  let(:orders) { {} }
  let(:ios) { Entities::IntendedOrders.new(orders) }

  describe '#validate!' do
    subject { order.validate!(orders: ios) }

    # ITA A Ven
    let(:ven_unit_position) { build(:unit_position, :army, turn:, territory: t_ven, country: country_ita) }
    # ITA A Tyr
    let(:tyr_unit_position) { build(:unit_position, :army, turn:, territory: t_tyr, country: country_ita) }

    let(:orders) do
      {
        # ITA A Ven H
        ven: build(:intended_order, :hold, turn:, unit_position: ven_unit_position),
        # ITA A Tyr S A Ven H
        tyr: build(:intended_order, :support_hold, turn:, unit_position: tyr_unit_position, from_territory: t_ven)
      }
    end
    let(:order) { orders[:tyr] }

    context 'when unopposed' do
      it 'succeeds the order' do
        subject
        expect(order).to be_successful
      end
    end

    context 'when unit is dislodged' do
      let(:tyr_unit_position) { build(:unit_position, :army, :dislodged, turn:, territory: t_tyr) }
      let(:order) { orders[:tyr] }

      it 'fails the order' do
        subject
        expect(order).to be_failed
        expect(order.errors.first.type).to eq :unit_dislodged
      end
    end

    context 'when supported unit is dislodged' do
      let(:ven_unit_position) { build(:unit_position, :army, :dislodged, turn:, territory: t_ven) }
      let(:order) { orders[:tyr] }

      it 'fails the order' do
        subject
        expect(order).to be_failed
        expect(order.errors.first.type).to eq :supported_unit_dislodged
      end
    end

    context 'when no unit at target territory' do
      let(:orders) do
        {
          # ITA A Tyr S A Ven H
          tyr: build(:intended_order, :support_hold, turn:, unit_position: tyr_unit_position, from_territory: t_ven)
        }
      end
      let(:order) { orders[:tyr]}

      it 'fails the order' do
        subject
        expect(order).to be_failed
        expect(order.errors.first.type).to eq :no_unit_at_supported_territory
      end
    end

    context 'when the unit is a unit type that cannot move to the area it is supporting' do
      # ITA F Adr
      let(:adr_unit_position) { build(:unit_position, :fleet, turn:, territory: t_adr, country: country_ita) }
      let(:orders) do
        {
          # ITA A Ven S F Adr H
          ven: build(:intended_order, :support_hold, turn:, unit_position: ven_unit_position, from_territory: t_adr),
          # ITA F Adr H
          adr: build(:intended_order, :hold, turn:, unit_position: tyr_unit_position, to_territory: t_adr)
        }
      end
      let(:order) { orders[:ven] }

      it 'fails the order' do
        subject
        expect(order).to be_failed
        expect(order.errors.first.type).to eq :invalid_unit_type
      end
    end

    context 'when the support order is for a unit that is not holding' do
      let(:orders) do
        {
          # ITA A Ven -> Pie
          ven: build(:intended_order, :move, turn:, unit_position: ven_unit_position, to_territory: t_pie),
          # ITA A Tyr S A Ven H
          tyr: build(:intended_order, :support_hold, turn:, unit_position: tyr_unit_position, from_territory: t_ven)
        }
      end
      let(:order) { orders[:tyr] }

      it 'fails the order' do
        subject
        expect(order).to be_failed
        expect(order.errors.first.type).to eq :supported_unit_moved
      end
    end

    context 'when support is cut' do
      # GER A Mun
      let(:mun_unit_position) { build(:unit_position, :army, turn:, territory: t_mun, country: country_ger) }
      let(:orders) do
        {
          # ITA A Ven H
          ven: build(:intended_order, :hold, turn:, unit_position: ven_unit_position, to_territory: t_ven),
          # ITA A Tyr S A Ven H
          tyr: build(:intended_order, :support_hold, turn:, unit_position: tyr_unit_position, from_territory: t_ven),
          # GER A Mun -> Tyr
          mun: build(:intended_order, :move, turn:, unit_position: mun_unit_position, to_territory: t_tyr)
        }
      end
      let(:order) { orders[:tyr] }

      it 'fails the order with a :support_cut code' do
        subject
        expect(order).to be_failed
        expect(order.errors.first.type).to eq :support_cut
      end
    end

    context 'when supporting a convoying ship' do
      let(:apu_unit_position) { build(:unit_position, :army, turn:, territory: t_apu, country: country_ita) }
      let(:adr_unit_position) { build(:unit_position, :fleet, turn:, territory: t_adr, country: country_ita) }
      let(:ven_unit_position) { build(:unit_position, :fleet, turn:, territory: t_ven, country: country_ita) }
      let(:orders) do
        {
          # ITA A Apu -> Tri
          apu: build(:intended_order, :move, turn:, unit_position: apu_unit_position, to_territory: t_tri),
          # ITA F Adr (C) Apu -> Tri
          adr: build(:intended_order, :convoy, turn:, unit_position: adr_unit_position, from_territory: t_apu, to_territory: t_tri),
          # ITA F Ven (S) A Adr (C) Apu -> Tri
          ven: build(:intended_order, :support_hold, turn:, unit_position: ven_unit_position, from_territory: t_apu, to_territory: t_tri)
        }
      end
      let(:order) { orders[:ven] }

      it 'succeeds the order' do
        subject
        expect(order).to be_successful
      end
    end
  end
end
