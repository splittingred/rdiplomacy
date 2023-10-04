# frozen_string_literal: true

describe IntendedOrders::SupportMove, variant: :classic do
  let(:turn) { build(:turn) }
  let(:orders) { {} }
  let(:ios) { Entities::IntendedOrders.new(orders) }

  describe '#validate!' do
    subject { order.validate!(orders: ios) }

    # ITA A Ven
    let(:ven_unit_position) { build(:unit_position, :army, turn:, territory: t_ven, country: country_ita) }
    # ITA A Tyr
    let(:tyr_unit_position) { build(:unit_position, :army, turn:, territory: t_tyr, country: country_ita) }
    # GER A Mun
    let(:mun_unit_position) { build(:unit_position, :army, turn:, territory: t_mun, country: country_ger) }

    let(:orders) do
      {
        # ITA A Ven -> Tri
        ven: build(:intended_order, :move, turn:, unit_position: ven_unit_position, to_territory: t_tri),
        # ITA A Tyr S A Ven -> Tri
        tyr: build(:intended_order, :support_move, turn:, unit_position: tyr_unit_position, from_territory: t_ven, to_territory: t_tri)
      }
    end
    let(:order) { orders[:tyr] }

    context 'when unit is unopposed' do
      it 'succeeds the order' do
        subject
        expect(order).to be_successful
      end
    end

    context 'when unit is dislodged' do
      let(:tyr_unit_position) { build(:unit_position, :army, :dislodged, turn:, territory: t_tyr, country: country_ita) }

      it 'fails the order with a :unit_dislodged code' do
        subject
        expect(order).to be_failed
        expect(order.errors.first.type).to eq :unit_dislodged
      end
    end

    context 'when supported unit is dislodged' do
      let(:ven_unit_position) { build(:unit_position, :army, :dislodged, turn:, territory: t_ven, country: country_ita) }

      it 'fails the order with a :supported_unit_dislodged code' do
        subject
        expect(order).to be_failed
        expect(order.errors.first.type).to eq :supported_unit_dislodged
      end
    end

    context 'when support is cut' do
      # GER A Mun
      let(:mun_unit_position) { build(:unit_position, :army, turn:, territory: t_mun, country: country_ger) }
      let(:orders) do
        {
          # ITA A Ven -> Tri
          ven: build(:intended_order, :move, turn:, unit_position: ven_unit_position, to_territory: t_tri),
          # ITA A Tyr S A Ven -> Tri
          tyr: build(:intended_order, :support_move, turn:, unit_position: tyr_unit_position, from_territory: t_ven, to_territory: t_tri),
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

    context 'when the unit moves to a different place than the supporting unit thought it would' do
      let(:orders) do
        {
          # ITA A Ven -> Pie
          ven: build(:intended_order, :move, turn:, unit_position: ven_unit_position, to_territory: t_pie),
          # ITA A Tyr S A Ven -> Tri
          tyr: build(:intended_order, :support_move, turn:, unit_position: tyr_unit_position, from_territory: t_ven, to_territory: t_tri)
        }
      end
      let(:order) { orders[:tyr] }

      it 'fails the order' do
        subject
        expect(order).to be_failed
        expect(order.errors.first.type).to eq :supported_unit_moved_elsewhere
      end
    end

    context 'when the unit is a unit type that cannot move to the area it is supporting' do
      # ITA F Tri
      let(:tri_unit_position) { build(:unit_position, :fleet, turn:, territory: t_tri, country: country_ita) }
      let(:orders) do
        {
          # ITA A Ven -> Tyr
          ven: build(:intended_order, :move, turn:, unit_position: ven_unit_position, to_territory: t_tyr),
          # ITA F Tri S A Ven -> Tyr
          tri: build(:intended_order, :support_move, turn:, unit_position: tri_unit_position, from_territory: t_ven, to_territory: t_tyr)
        }
      end
      let(:order) { orders[:tri] }

      it 'fails the order' do
        subject
        expect(order).to be_failed
        expect(order.errors.first.type).to eq :invalid_unit_type
      end
    end
  end
end
