# frozen_string_literal: true

describe IntendedOrders::Move, variant: :classic do
  let(:turn) { build :turn }
  let(:orders) { {} }
  let(:ios) { Entities::IntendedOrders.new(orders) }

  # ITA A Ven
  let(:ven_unit_position) { build(:unit_position, :army, turn:, territory: t_ven, country: country_ita) }
  # GER A Mun
  let(:mun_unit_position) { build(:unit_position, :army, turn:, territory: t_mun, country: country_ger) }
  # FRA A Pie
  let(:pie_unit_position) { build(:unit_position, :army, turn:, territory: t_pie, country: country_fra) }
  # ITA A Tri
  let(:tri_unit_position) { build(:unit_position, :army, turn:, territory: t_tri, country: country_ita) }

  describe '#validate!' do
    subject { order.validate!(orders: ios) }

    let(:order) { orders[:ven] }

    context 'with move orders' do
      context 'when unit is not already dislodged' do
        context 'when unit is not convoyed' do
          context 'when unit is unopposed' do
            let(:orders) do
              {
                # ITA A Ven -> Tyr
                ven: build(:intended_order, :move, turn:, unit_position: ven_unit_position, to_territory: t_tyr)
              }
            end

            it 'succeeds the order' do
              subject
              expect(order).to be_successful
            end
          end

          context 'when unit is opposed' do
            # ITA A Ven -> Tyr

            context 'when unit has equal strength' do
              let(:orders) do
                {
                  # ITA A Ven -> Tyr
                  ven: build(:intended_order, :move, unit_position: ven_unit_position, to_territory: t_tyr),
                  # GER A Mun -> Tyr
                  mun: build(:intended_order, :move, unit_position: mun_unit_position, to_territory: t_tyr)
                  # - fails, 1 ITA vs 1 GER
                }
              end

              it 'fails the order' do
                subject
                expect(order).to be_failed
                expect(order.errors.first.type).to eq :move_failed
              end
            end

            context 'when unit has greater strength' do
              let(:orders) do
                {
                  # ITA A Ven -> Tyr
                  ven: build(:intended_order, :move, unit_position: ven_unit_position, to_territory: t_tyr),
                  # ITA A Tri S A Ven -> Tyr
                  tri: build(:intended_order, :support_move, unit_position: tri_unit_position, from_territory: t_ven, to_territory: t_tyr),
                  # GER A Mun -> Tyr
                  mun: build(:intended_order, :move, unit_position: mun_unit_position, to_territory: t_tyr)
                  # - succeeds, 2 ITA vs 1 GER
                }
              end

              it 'succeeds the order' do
                subject
                expect(order).to be_successful
              end
            end

            context 'when unit has less strength' do
              let(:orders) do
                {
                  # ITA A Ven -> Tyr
                  ven: build(:intended_order, :move, unit_position: ven_unit_position, from_territory: t_ven, to_territory: t_tyr),
                  # GER A Mun -> Tyr
                  mun: build(:intended_order, :move, unit_position: mun_unit_position, from_territory: t_mun, to_territory: t_tyr),
                  # FRA A Pie S GER A Mun -> Tyr
                  pie: build(:intended_order, :support_move, unit_position: pie_unit_position, from_territory: t_mun, to_territory: t_tyr)
                  # - fails, 2 GER+FRA + 1 ITA
                }
              end

              it 'fails the order' do
                subject
                expect(order).to be_failed
                expect(order.errors.first.type).to eq :move_failed
              end
            end
          end
        end

        context 'when unit is convoyed' do
          # TODO: specs for convoying
        end
      end

      context 'when unit is already dislodged' do
        let(:ven_unit_position) { build(:unit_position, :army, :dislodged, turn:, territory: t_ven, country: country_ita) }
        let(:orders) do
          {
            # ITA A Ven -> Tyr
            ven: build(:intended_order, :move, unit_position: ven_unit_position, to_territory: t_tyr)
          }
        end

        it 'fails the order' do
          subject
          expect(order).to be_failed
          expect(order.errors.first.type).to eq :unit_dislodged
        end
      end
    end
  end
end
