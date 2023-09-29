# frozen_string_literal: true

# rubocop:disable RSpec/EmptyExampleGroup
describe Orders::AdjudicationService, countries: :classic, territories: :classic do
  let(:service) { described_class.new }
  let(:orders) { {} }
  let(:ios) { Entities::IntendedOrders.new(orders) }
  let(:game) { build(:game) }

  describe '#call' do
    subject { service.call(ios) }

    let(:resulting_orders) { subject.value!.orders }

    context 'with hold orders' do
      let(:ven_unit) { build(:unit, game:, country: country_ita) }
      let(:ven_unit_position) { build(:unit_position, unit: ven_unit, turn: game.current_turn, territory: t_ven) }
      let(:orders) do
        {
          ven: build(:intended_order, :hold, game:, unit_position: ven_unit_position, unit: ven_unit, from_territory: t_ven, country: country_ita) # F VEN H
        }
      end

      context 'when unit is not already dislodged' do
        it 'succeeds the order' do
          expect(subject).to be_a_success
          expect(resulting_orders[:ven]).to be_successful
        end
      end

      context 'when unit is already dislodged' do
        let(:ven_unit_position) { build(:unit_position, :dislodged, unit: ven_unit, turn: game.current_turn, territory: t_ven) }

        it 'fails the order' do
          expect(subject).to be_a_success
          expect(resulting_orders[:ven]).to be_failed
        end
      end
    end

    context 'with move orders' do
      # ITA A Ven
      let(:ven_unit) { build(:unit, game:, country: country_ita) }
      let(:ven_unit_position) { build(:unit_position, unit: ven_unit, turn: game.current_turn, territory: t_ven) }

      context 'when unit is not already dislodged' do
        context 'when unit is not convoyed' do
          context 'when unit is unopposed' do
            let(:orders) do
              {
                # ITA A Ven -> Tyr
                ven: build(:intended_order, :move, game:, unit_position: ven_unit_position, unit: ven_unit, from_territory: t_ven, to_territory: t_tyr, country: country_ita)
              }
            end

            it 'succeeds the order' do
              expect(subject).to be_a_success
              expect(resulting_orders[:ven]).to be_successful
            end
          end

          context 'when unit is opposed' do
            # GER A Mun
            let(:mun_unit) { build(:unit, :army, game:, country: country_ger) }
            let(:mun_unit_position) { build(:unit_position, unit: mun_unit, turn: game.current_turn, territory: t_mun) }
            # FRA A Pie
            let(:pie_unit) { build(:unit, :army, game:, country: country_fra) }
            let(:pie_unit_position) { build(:unit_position, unit: pie_unit, turn: game.current_turn, territory: t_pie) }
            # ITA A Tri
            let(:tri_unit) { build(:unit, :army, game:, country: country_ita) }
            let(:tri_unit_position) { build(:unit_position, unit: tri_unit, turn: game.current_turn, territory: t_tri) }

            context 'when unit has equal strength' do
              let(:orders) do
                super().merge(
                  # ITA A Ven -> Tyr
                  ven: build(:intended_order, :move, game:, unit_position: ven_unit_position, unit: ven_unit, from_territory: t_ven, to_territory: t_tyr, country: country_ita),
                  # GER A Mun -> Tyr
                  mun: build(:intended_order, :move, game:, unit_position: mun_unit_position, unit: mun_unit, from_territory: t_mun, to_territory: t_tyr, country: country_ger)
                  # - fails, 1 ITA vs 1 GER
                )
              end

              it 'fails the order' do
                expect(subject).to be_a_success
                expect(resulting_orders[:ven]).to be_failed
                expect(resulting_orders[:ven].errors.first.type).to eq :move_failed
              end
            end

            context 'when unit has greater strength' do
              let(:orders) do
                {
                  # ITA A Ven -> Tyr
                  ven: build(:intended_order, :move, game:, unit_position: ven_unit_position, unit: ven_unit, from_territory: t_ven, to_territory: t_tyr, country: country_ita),
                  # ITA A Tri S A Ven -> Tyr
                  tri: build(:intended_order, :support_move, game:, unit_position: tri_unit_position, unit: tri_unit, from_territory: t_ven, to_territory: t_tyr, assistance_territory: t_tri, country: country_ita),
                  # GER A Mun -> Tyr
                  mun: build(:intended_order, :move, game:, unit_position: mun_unit_position, unit: mun_unit, from_territory: t_mun, to_territory: t_tyr, country: country_ger)
                  # - succeeds, 2 ITA vs 1 GER
                }
              end

              it 'succeeds the order' do
                expect(subject).to be_a_success
                expect(resulting_orders[:ven]).to be_successful
              end
            end

            context 'when unit has less strength' do
              let(:orders) do
                {
                  # ITA A Ven -> Tyr
                  ven: build(:intended_order, :move, game:, unit_position: ven_unit_position, unit: ven_unit, from_territory: t_ven, to_territory: t_tyr, country: country_ita),
                  # GER A Mun -> Tyr
                  mun: build(:intended_order, :move, game:, unit_position: mun_unit_position, unit: mun_unit, from_territory: t_mun, to_territory: t_tyr, country: country_ger),
                  # FRA A Pie S GER A Mun -> Tyr
                  pie: build(:intended_order, :support_move, game:, unit_position: pie_unit_position, unit: pie_unit, from_territory: t_mun, to_territory: t_tyr, assistance_territory: t_pie, country: country_fra)
                  # - fails, 2 GER+FRA + 1 ITA
                }
              end

              it 'fails the order' do
                expect(subject).to be_a_success
                expect(resulting_orders[:ven]).to be_failed
                expect(resulting_orders[:ven].errors.first.type).to eq :move_failed
              end
            end
          end
        end

        context 'when unit is convoyed' do
          # TODO: specs for convoying
        end
      end

      context 'when unit is already dislodged' do
        let(:ven_unit_position) { build(:unit_position, :dislodged, unit: ven_unit, turn: game.current_turn, territory: t_ven) }
        let(:orders) do
          {
            # ITA A Ven -> Tyr
            ven: build(:intended_order, :move, game:, unit_position: ven_unit_position, unit: ven_unit, from_territory: t_ven, to_territory: t_tyr, country: country_ita)
          }
        end

        it 'fails the order' do
          expect(subject).to be_a_success
          expect(resulting_orders[:ven]).to be_failed
          expect(resulting_orders[:ven].errors.first.type).to eq :unit_dislodged
        end
      end
    end

    context 'with support hold orders' do
      # ITA A Ven
      let(:ven_unit) { build(:unit, game:, country: country_ita) }
      let(:ven_unit_position) { build(:unit_position, unit: ven_unit, turn: game.current_turn, territory: t_ven) }
      # ITA A Tyr
      let(:tyr_unit) { build(:unit, :army, game:, country: country_ita) }
      let(:tyr_unit_position) { build(:unit_position, unit: tyr_unit, turn: game.current_turn, territory: t_tyr) }
      let(:orders) do
        {
          # ITA A Ven H
          ven: build(:intended_order, :hold, game:, unit_position: ven_unit_position, unit: ven_unit, from_territory: t_ven, to_territory: t_ven, country: country_ita),
          # ITA A Tyr S A Ven H
          tyr: build(:intended_order, :support_hold, game:, unit_position: tyr_unit_position, unit: tyr_unit, from_territory: t_ven, to_territory: t_ven, assistance_territory: t_tyr, country: country_ita)
        }
      end

      context 'when unopposed' do
        it 'succeeds the order' do
          expect(subject).to be_a_success
          expect(resulting_orders[:tyr]).to be_successful
        end
      end

      context 'when unit is dislodged' do
        let(:ven_unit_position) { build(:unit_position, :dislodged, unit: ven_unit, turn: game.current_turn, territory: t_ven) }

        it 'fails the order' do
          expect(subject).to be_a_success
          expect(resulting_orders[:ven]).to be_failed
          expect(resulting_orders[:ven].errors.first.type).to eq :unit_dislodged
        end
      end

      context 'when no unit at target territory' do
        let(:orders) do
          super().tap { |os| os.delete(:ven) }
        end

        it 'fails the order' do
          expect(subject).to be_a_success
          expect(resulting_orders[:tyr]).to be_failed
          expect(resulting_orders[:tyr].errors.first.type).to eq :no_unit_at_supported_territory
        end
      end

      context 'when the unit is a unit type that cannot move to the area it is supporting' do
        # ITA F Adr
        let(:adr_unit) { build(:unit, :fleet, game:, country: country_ita) }
        let(:adr_unit_position) { build(:unit_position, unit: adr_unit, turn: game.current_turn, territory: t_adr) }
        let(:orders) do
          {
            # ITA A Ven S F Adr H
            ven: build(:intended_order, :support_hold, game:, unit_position: ven_unit_position, unit: ven_unit, from_territory: t_adr, to_territory: t_adr, assistance_territory: t_ven, country: country_ita),
            # ITA F Adr H
            adr: build(:intended_order, :hold, game:, unit_position: tyr_unit_position, unit: tyr_unit, from_territory: t_adr, to_territory: t_adr, country: country_ita)
          }
        end

        it 'fails the order' do
          expect(subject).to be_a_success
          expect(resulting_orders[:ven]).to be_failed
          expect(resulting_orders[:ven].errors.first.type).to eq :invalid_unit_type
        end
      end

      context 'when the support order is for a unit that is not holding' do
        let(:orders) do
          {
            # ITA A Ven -> Pie
            ven: build(:intended_order, :move, game:, unit_position: ven_unit_position, unit: ven_unit, from_territory: t_ven, to_territory: t_pie, country: country_ita),
            # ITA A Tyr S A Ven H
            tyr: build(:intended_order, :support_hold, game:, unit_position: tyr_unit_position, unit: tyr_unit, from_territory: t_ven, to_territory: t_ven, assistance_territory: t_tyr, country: country_ita)
          }
        end

        it 'fails the order' do
          expect(subject).to be_a_success
          expect(resulting_orders[:tyr]).to be_failed
          expect(resulting_orders[:tyr].errors.first.type).to eq :supported_unit_moved
        end
      end

      context 'when support is cut' do
        # GER A Mun
        let(:mun_unit) { build(:unit, :army, game:, country: country_ger) }
        let(:mun_unit_position) { build(:unit_position, unit: mun_unit, turn: game.current_turn, territory: t_mun) }
        let(:orders) do
          super().merge(
            # GER A Mun -> Tyr
            mun: build(:intended_order, :move, game:, unit_position: mun_unit_position, unit: mun_unit, from_territory: t_mun, to_territory: t_tyr, country: country_ger)
          )
        end

        it 'fails the order with a :support_cut code' do
          expect(subject).to be_a_success
          expect(resulting_orders[:tyr]).to be_failed
          expect(resulting_orders[:tyr].errors.first.type).to eq :support_cut
        end
      end

      context 'when supporting a convoying ship' do
        let(:apu_unit) { build(:unit, :army, game:, country: country_ita) }
        let(:apu_unit_position) { build(:unit_position, unit: apu_unit, turn: game.current_turn, territory: t_apu) }
        let(:adr_unit) { build(:unit, :fleet, game:, country: country_ita) }
        let(:adr_unit_position) { build(:unit_position, unit: adr_unit, turn: game.current_turn, territory: t_adr) }
        let(:ven_unit) { build(:unit, :fleet, game:, country: country_ita) }
        let(:ven_unit_position) { build(:unit_position, unit: ven_unit, turn: game.current_turn, territory: t_ven) }
        let(:orders) do
          {
            # ITA A Apu -> Tri
            apu: build(:intended_order, :move, game:, unit_position: apu_unit_position, unit: apu_unit, from_territory: t_apu, to_territory: t_tri, country: country_ita),
            # ITA F Adr (C) Apu -> Tri
            adr: build(:intended_order, :convoy, game:, unit_position: adr_unit_position, unit: adr_unit, from_territory: t_ven, to_territory: t_tyr, assistance_territory: t_adr, country: country_ita),
            # ITA F Ven (S) A Adr (C) Apu -> Tri
            ven: build(:intended_order, :support_hold, game:, unit_position: ven_unit_position, unit: ven_unit, from_territory: t_apu, to_territory: t_tri, country: country_ita)
          }
        end

        it 'succeeds the order' do
          expect(subject).to be_a_success
          expect(resulting_orders[:ven]).to be_successful
        end
      end
    end

    context 'with support move orders' do
      # ITA A Ven
      let(:ven_unit) { build(:unit, game:, country: country_ita) }
      let(:ven_unit_position) { build(:unit_position, unit: ven_unit, turn: game.current_turn, territory: t_ven) }
      # ITA A Tyr
      let(:tyr_unit) { build(:unit, :army, game:, country: country_ita) }
      let(:tyr_unit_position) { build(:unit_position, unit: tyr_unit, turn: game.current_turn, territory: t_tyr) }
      # GER A Mun
      let(:mun_unit) { build(:unit, :army, game:, country: country_ger) }
      let(:mun_unit_position) { build(:unit_position, unit: mun_unit, turn: game.current_turn, territory: t_mun) }

      let(:orders) do
        {
          # ITA A Ven -> Tri
          ven: build(:intended_order, :move, game:, unit_position: ven_unit_position, unit: ven_unit, from_territory: t_ven, to_territory: t_tri, country: country_ita),
          # ITA A Tyr S A Ven -> Tri
          tyr: build(:intended_order, :support_move, game:, unit_position: tyr_unit_position, unit: tyr_unit, from_territory: t_ven, to_territory: t_tri, assistance_territory: t_tyr, country: country_ita)
        }
      end

      context 'when unit is unopposed' do
        it 'succeeds the order' do
          expect(subject).to be_a_success
          expect(resulting_orders[:tyr]).to be_successful
        end
      end

      context 'when unit is dislodged' do
        let(:ven_unit_position) { build(:unit_position, :dislodged, unit: ven_unit, turn: game.current_turn, territory: t_ven) }

        it 'fails the order with a :unit_dislodged code' do
          expect(subject).to be_a_success
          expect(resulting_orders[:ven]).to be_failed
          expect(resulting_orders[:ven].errors.first.type).to eq :unit_dislodged
        end
      end

      context 'when support is cut' do
        # GER A Mun
        let(:mun_unit) { build(:unit, :army, game:, country: country_ger) }
        let(:mun_unit_position) { build(:unit_position, unit: mun_unit, turn: game.current_turn, territory: t_mun) }
        let(:orders) do
          super().merge(
            # GER A Mun -> Tyr
            mun: build(:intended_order, :move, game:, unit_position: mun_unit_position, unit: mun_unit, from_territory: t_mun, to_territory: t_tyr, country: country_ger)
          )
        end

        it 'fails the order with a :support_cut code' do
          expect(subject).to be_a_success
          expect(resulting_orders[:tyr]).to be_failed
          expect(resulting_orders[:tyr].errors.first.type).to eq :support_cut
        end
      end

      context 'when the unit moves to a different place than the supporting unit thought it would' do
        let(:orders) do
          {
            # ITA A Ven -> Pie
            ven: build(:intended_order, :move, game:, unit_position: ven_unit_position, unit: ven_unit, from_territory: t_ven, to_territory: t_pie, country: country_ita),
            # ITA A Tyr S A Ven -> Tri
            tyr: build(:intended_order, :support_move, game:, unit_position: tyr_unit_position, unit: tyr_unit, from_territory: t_ven, to_territory: t_tri, assistance_territory: t_tyr, country: country_ita)
          }
        end

        it 'fails the order' do
          expect(subject).to be_a_success
          expect(resulting_orders[:tyr]).to be_failed
          expect(resulting_orders[:tyr].errors.first.type).to eq :supported_unit_moved_elsewhere
        end
      end

      context 'when the unit is a unit type that cannot move to the area it is supporting' do
        # ITA F Tri
        let(:tri_unit) { build(:unit, :fleet, game:, country: country_ita) }
        let(:tri_unit_position) { build(:unit_position, unit: tri_unit, turn: game.current_turn, territory: t_tri) }
        let(:orders) do
          {
            # ITA A Ven -> Tyr
            ven: build(:intended_order, :move, game:, unit_position: ven_unit_position, unit: ven_unit, from_territory: t_ven, to_territory: t_tyr, country: country_ita),
            # ITA F Tri S A Ven -> Tyr
            tri: build(:intended_order, :support_move, game:, unit_position: tri_unit_position, unit: tri_unit, from_territory: t_ven, to_territory: t_tyr, assistance_territory: t_tri, country: country_ita)
          }
        end

        it 'fails the order' do
          expect(subject).to be_a_success
          expect(resulting_orders[:tri]).to be_failed
          expect(resulting_orders[:tri].errors.first.type).to eq :invalid_unit_type
        end
      end
    end

    context 'with convoy orders' do
      let(:tun_unit) { build(:unit, :army, game:, country: country_ita) }
      let(:tun_unit_position) { build(:unit_position, unit: tun_unit, turn: game.current_turn, territory: t_tun) }
      let(:ion_unit) { build(:unit, :fleet, game:, country: country_ita) }
      let(:ion_unit_position) { build(:unit_position, unit: ion_unit, turn: game.current_turn, territory: t_ion) }
      let(:orders) do
        {
          # ITA A Tun -> Gre
          tun: build(:intended_order, :move, game:, unit_position: tun_unit_position, unit: tun_unit, from_territory: t_tun, to_territory: t_gre, country: country_ita),
          # ITA F ION (C) Tun -> Gre
          ion: build(:intended_order, :convoy, game:, unit_position: ion_unit_position, unit: ion_unit, from_territory: t_tun, to_territory: t_gre, assistance_territory: t_ion, country: country_ita)
        }
      end

      context 'with a single fleet' do
        context 'when the path is correct' do
          it 'succeeds all orders' do
            expect(subject).to be_a_success
            expect(resulting_orders[:tun]).to be_successful
            expect(resulting_orders[:ion]).to be_successful
          end
        end

        context 'when the path is incorrect' do
          # TODO: do pathing algorithm for convoys
        end
      end

      context 'with multiple fleets' do
        let(:aeg_unit) { build(:unit, :fleet, game:, country: country_ita) }
        let(:aeg_unit_position) { build(:unit_position, unit: aeg_unit, turn: game.current_turn, territory: t_aeg) }

        let(:orders) do
          super().merge(
            # ITA A Tun -> Gre
            tun: build(:intended_order, :move, game:, unit_position: tun_unit_position, unit: tun_unit, from_territory: t_tun, to_territory: t_smy, country: country_ita),
            # ITA F ION (C) Tun -> Smy
            ion: build(:intended_order, :convoy, game:, unit_position: ion_unit_position, unit: ion_unit, from_territory: t_tun, to_territory: t_smy, assistance_territory: t_ion, country: country_ita),
            # ITA F AEG (C) Tun -> Smy
            aeg: build(:intended_order, :convoy, game:, unit_position: aeg_unit_position, unit: aeg_unit, from_territory: t_tun, to_territory: t_smy, assistance_territory: t_aeg, country: country_ita)
          )
        end

        context 'when the path is correct' do
          it 'succeeds all orders' do
            expect(subject).to be_a_success
            expect(resulting_orders[:tun]).to be_successful
            expect(resulting_orders[:ion]).to be_successful
            expect(resulting_orders[:aeg]).to be_successful
          end
        end

        context 'when the path is incorrect' do
          # TODO: do pathing algorithm for convoys
        end
      end
    end

    context 'with retreat orders' do
      # TODO: specs
    end

    context 'with build orders' do
      # TODO: specs
    end

    context 'with disband orders' do
      # TODO: specs
    end
  end
end
# rubocop:enable RSpec/EmptyExampleGroup
