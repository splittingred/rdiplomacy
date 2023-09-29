# frozen_string_literal: true

describe IntendedOrders::Convoy, variant: :classic do
  let(:turn) { build(:turn) }
  let(:orders) { {} }
  let(:ios) { Entities::IntendedOrders.new(orders) }

  let(:tun_unit_position) { build(:unit_position, :army, territory: t_tun, country: country_ita) }
  let(:ion_unit_position) { build(:unit_position, :fleet, territory: t_ion, country: country_ita) }

  describe '#validate!' do
    subject do
      orders.each_value { |o| o.validate!(orders: ios) }
    end

    let(:orders) do
      {
        # ITA A Tun -> Gre
        tun: build(:intended_order, :move, :convoyed, turn:, unit_position: tun_unit_position, to_territory: t_gre),
        # ITA F ION (C) Tun -> Gre
        ion: build(:intended_order, :convoy, turn:, unit_position: ion_unit_position, from_territory: t_tun, to_territory: t_gre)
      }
    end
    let(:order) { orders[:ion] }

    context 'with a single fleet' do
      context 'when the path is correct' do
        it 'succeeds all orders' do
          subject
          expect(orders[:tun]).to be_successful
          expect(orders[:ion]).to be_successful
        end
      end

      context 'when the path is incorrect' do
        # TODO: do pathing algorithm for convoys
      end
    end

    context 'with multiple fleets' do
      let(:aeg_unit_position) { build(:unit_position, :fleet, turn:, territory: t_aeg, country: country_ita) }

      let(:orders) do
        {
          # ITA A Tun -> Gre
          tun: build(:intended_order, :move, :convoyed, game:, unit_position: tun_unit_position, to_territory: t_smy),
          # ITA F ION (C) Tun -> Smy
          ion: build(:intended_order, :convoy, game:, unit_position: ion_unit_position, from_territory: t_tun, to_territory: t_smy),
          # ITA F AEG (C) Tun -> Smy
          aeg: build(:intended_order, :convoy, game:, unit_position: aeg_unit_position, from_territory: t_tun, to_territory: t_smy)
        }
      end
      let(:order) { orders[:ion] }

      context 'when the path is correct' do
        it 'succeeds all orders' do
          subject
          expect(orders[:tun]).to be_successful
          expect(orders[:ion]).to be_successful
          expect(orders[:aeg]).to be_successful
        end
      end

      context 'when the path is incorrect' do
        # TODO: do pathing algorithm for convoys
      end
    end
  end
end
