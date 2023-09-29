# frozen_string_literal: true

describe Entities::IntendedOrders, countries: :classic, territories: :classic do
  let(:ios) { described_class.new(orders) }
  let(:game) { build :game }
  let(:turn) { build :turn, game: }
  let(:orders) { {} }

  describe '#successful_move_order_to' do
    subject { ios.successful_move_order_to(destination) }

    let(:destination) { t_ion }
    let(:nap_u) { build(:unit, :fleet, game:, country: country_ita) }
    let(:nap_up) { build(:unit_position, unit: nap_u, turn:, territory: t_nap) }
    let(:apu_u) { build(:unit, :fleet, game:, country: country_ita) }
    let(:apu_up) { build(:unit_position, unit: apu_u, turn:, territory: t_apu) }
    let(:adr_u) { build(:unit, :fleet, game:, country: country_ita) }
    let(:adr_up) { build(:unit_position, unit: adr_u, turn:, territory: t_adr) }

    let(:tys_u) { build(:unit, :fleet, game:, country: country_fra) }
    let(:tys_up) { build(:unit_position, unit: tys_u, turn:, territory: t_tys) }
    let(:tun_u) { build(:unit, :fleet, game:, country: country_fra) }
    let(:tun_up) { build(:unit_position, unit: tun_u, turn:, territory: t_tun) }

    context 'when there are no competing moves to the territory' do
      let(:orders) do
        {
          nap: build(:intended_order, :move, unit: nap_u, unit_position: nap_up, from_territory: t_nap, to_territory: t_ion, country: country_ita) # F NAP - ION
        }
      end

      it 'returns the same order' do
        expect(subject).to eq(orders[:nap])
      end
    end

    context 'when there are competing moves' do
      let(:orders) do
        {
          # ITA F Nap - ION
          nap: build(:intended_order, :move, unit_position: nap_up, to_territory: destination),
          # FRA F Tun - ION
          tun: build(:intended_order, :move, unit_position: tun_up, to_territory: destination)
        }
      end

      context 'when moves are unsupported' do
        it 'returns nil as they bounce' do
          expect(subject).to be_nil
        end
      end

      context 'when one has support and other does not' do
        let(:orders) do
          super().merge(
            # ITA F Apu (S) F Nap - ION
            apu: build(:intended_order, :support_move, unit_position: apu_up, assistance_territory: t_apu, from_territory: t_nap, to_territory: t_ion)
          )
        end

        it 'returns the winning move' do
          expect(subject).to eq(orders[:nap])
        end
      end

      context 'when moves are both supported' do
        context 'when one has more support' do
          let(:orders) do
            super().merge(
              # ITA F Apu (S) F Nap - ION
              apu: build(:intended_order, :support_move, unit_position: tun_up, assistance_territory: t_apu, from_territory: t_nap, to_territory: t_ion),
              # ITA F Adr (S) F Nap - ION
              adr: build(:intended_order, :support_move, unit_position: adr_up, assistance_territory: t_adr, from_territory: t_nap, to_territory: t_ion),
              # FRA F Tys (S) F Nap - ION
              tys: build(:intended_order, :support_move, unit_position: tys_up, assistance_territory: t_tys, from_territory: t_nap, to_territory: t_ion)
            )
          end

          it 'returns the winning move' do
            expect(subject).to eq(orders[:nap])
          end
        end

        context 'when the moves are equal in strength' do
          let(:orders) do
            {
              # ITA F Nap - ION
              nap: build(:intended_order, :move, unit_position: nap_up, from_territory: t_nap, to_territory: destination),
              # ITA F Apu (S) F Nap - ION
              apu: build(:intended_order, :support_move, unit_position: apu_up, assistance_territory: t_apu, from_territory: t_nap, to_territory: destination),
              # FRA F Tun - ION
              tun: build(:intended_order, :move, unit_position: tun_up, from_territory: t_tun, to_territory: destination),
              # FRA F Tys (S) F Tun - ION
              tys: build(:intended_order, :support_move, unit_position: tys_up, assistance_territory: t_tys, from_territory: t_tun, to_territory: destination)
            }
          end

          it 'returns nil as they bounce' do
            expect(subject).to be_nil
          end
        end
      end
    end
  end

  describe '#moves_to' do
    subject { ios.moves_to(destination) }

    let(:nap_u) { build(:unit, :fleet, game:, country: country_ita) }
    let(:nap_up) { build(:unit_position, unit: nap_u, turn:, territory: t_nap) }
    let(:eas_u) { build(:unit, :fleet, game:, country: country_ita) }
    let(:eas_up) { build(:unit_position, unit: eas_u, turn:, territory: t_eas) }

    context 'when the destination has moves to it' do
      let(:destination) { t_ion }
      let(:orders) do
        {
          # F NAP - ION
          nap: build(:intended_order, :move, turn:, unit_position: nap_up, to_territory: t_ion),
          # F EAS - ION
          eas: build(:intended_order, :move, turn:, unit_position: eas_up, to_territory: t_ion)
        }
      end

      it 'returns the moves to a territory' do
        expect(subject.size).to eq(2)
      end
    end

    context 'when the destination has no moves to it' do
      let(:destination) { t_aeg }
      let(:orders) do
        {
          # F NAP - ION
          nap: build(:intended_order, :move, turn:, unit_position: nap_up, to_territory: t_ion)
        }
      end

      it 'returns zero moves' do
        expect(subject.size).to eq(0)
      end
    end
  end

  describe '#from' do
    subject { ios.from(from) }

    let(:nap_u) { build(:unit, :fleet, game:, country: country_ita) }
    let(:nap_up) { build(:unit_position, unit: nap_u, turn:, territory: t_nap) }
    let(:eas_u) { build(:unit, :fleet, game:, country: country_ita) }
    let(:eas_up) { build(:unit_position, unit: eas_u, turn:, territory: t_eas) }
    let(:from) { t_nap }
    let(:orders) do
      {
        # F NAP - ION
        nap: build(:intended_order, :move, turn:, unit_position: nap_up, to_territory: t_ion),
        # F EAS - ION
        eas: build(:intended_order, :move, turn:, unit_position: eas_up, to_territory: t_ion)
      }
    end

    context 'when there are orders from the territory' do
      let(:from) { t_nap }

      it 'returns the order' do
        expect(subject).to eq(orders[:nap])
      end
    end

    context 'when there are no orders from the territory' do
      let(:from) { t_syr }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end

  describe '#hold_strength_for' do
    subject { ios.hold_strength(territory) }

    let(:nap_up) { build(:unit_position, turn:, country: country_ita, territory: t_nap) }
    let(:territory) { t_ion }
    let(:orders) do
      {
        # F Nap H - supported hold by Rom
        nap: build(:intended_order, :hold, turn:, unit_position: nap_up, from_territory: t_nap)
      }
    end

    context 'when there is a unit at the territory' do
      let(:territory) { t_nap }

      context 'when the unit is moving' do
        let(:orders) do
          super().merge(
            # F Nap -> F Ion
            nap: build(:intended_order, :move, turn:, unit_position: nap_up, to_territory: t_ion)
          )
        end

        it 'returns 0' do
          expect(subject).to eq 0
        end
      end

      context 'when the unit is holding' do
        context 'when the unit has no support' do
          it 'returns 1' do
            expect(subject).to eq 1
          end
        end

        context 'when the unit is supported' do
          let(:rom_up) { build(:unit_position, turn:, country: country_ita, territory: t_rom) }
          let(:ion_up) { build(:unit_position, turn:, country: country_ita, territory: t_ion) }
          let(:orders) do
            super().merge(
              # F Rom (S) F Nap H
              rom: build(:intended_order, :support_hold, unit_position: rom_up, turn:, assistance_territory: t_rom, from_territory: t_nap),
              # F ION (S) F Nap H
              ion: build(:intended_order, :support_hold, unit_position: ion_up, turn:, assistance_territory: t_ion, from_territory: t_nap)
            )
          end

          context 'when no supports are cut' do
            it 'returns 3' do
              expect(subject).to eq 3
            end
          end

          context 'when one support is cut' do
            let(:tus_up) { build(:unit_position, turn:, territory: t_tus, country: country_fra) }
            let(:orders) do
              super().merge(
                # FRA F Tus -> F Rom
                tus: build(:intended_order, :move, turn:, unit_position: tus_up, from_territory: t_tus, to_territory: t_rom)
              )
            end

            it 'returns 2' do
              expect(subject).to eq 2
            end
          end

          context 'when all support is cut' do
            let(:tus_up) { build(:unit_position, turn:, country: country_fra, territory: t_tus) }
            let(:tun_up) { build(:unit_position, turn:, country: country_fra, territory: t_tun) }
            let(:orders) do
              super().merge(
                # FRA F Tus -> F Rom
                tus: build(:intended_order, :move, turn:, unit_position: tus_up, to_territory: t_rom),
                # FRA F Tun -> F ION
                tun: build(:intended_order, :move, turn:, unit_position: tun_up, to_territory: t_ion)
              )
            end

            it 'returns 1' do
              expect(subject).to eq 1
            end
          end
        end
      end
    end

    context 'when there is no unit at the territory' do
      let(:territory) { t_syr }

      it 'returns 0' do
        expect(subject).to be_zero
      end
    end
  end

  describe '#move_strength_to' do
    subject { ios.move_strength_to(from: origin, to: destination) }

    let(:nap_u) { build(:unit, :fleet, game:, country: country_ita) }
    let(:nap_up) { build(:unit_position, unit: nap_u, turn:, territory: t_nap) }
    let(:origin) { t_nap }
    let(:destination) { t_ion }

    let(:orders) do
      {
        # F Nap - ION
        nap: build(:intended_order, :move, turn:, unit: nap_u, unit_position: nap_up, from_territory: t_nap, to_territory: t_ion, country: country_ita)
      }
    end

    context 'when unit is unsupported' do
      it 'returns 1' do
        expect(subject).to eq 1
      end
    end

    context 'when unit is supported' do
      let(:tys_u) { build(:unit, :fleet, game:, country: country_ita) }
      let(:tys_up) { build(:unit_position, unit: nap_u, turn:, territory: t_tys) }
      let(:apu_u) { build(:unit, :fleet, game:, country: country_ita) }
      let(:apu_up) { build(:unit_position, unit: apu_u, turn:, territory: t_apu) }

      let(:orders) do
        super().merge(
          # F TYS (S) F Nap - ION
          tys: build(:intended_order, :support_move, turn:, unit: tys_u, unit_position: tys_up, from_territory: t_nap, to_territory: t_ion, assistance_territory: t_tys, country: country_ita),
          # F Apu (S) F Nap - ION
          apu: build(:intended_order, :support_move, turn:, unit: apu_u, unit_position: apu_up, from_territory: t_nap, to_territory: t_ion, assistance_territory: t_apu, country: country_ita)
        )
      end

      context 'when no supports are cut' do
        it 'returns 3' do
          expect(subject).to eq 3
        end
      end

      context 'when one support is cut' do
        let(:tun_u) { build(:unit, :fleet, game:, country: country_fra) }
        let(:tun_up) { build(:unit_position, unit: tun_u, turn:, territory: t_tun) }
        let(:orders) do
          super().merge(
            # FRA F Tun -> TYS
            tun: build(:intended_order, :move, turn:, unit: tun_u, unit_position: tun_up, from_territory: t_tun, to_territory: t_tys, country: country_fra)
          )
        end

        it 'returns 2' do
          expect(subject).to eq 2
        end
      end

      context 'when both supports are cut' do
        let(:tun_u) { build(:unit, :fleet, game:, country: country_fra) }
        let(:tun_up) { build(:unit_position, unit: tun_u, turn:, territory: t_tun) }
        let(:ven_u) { build(:unit, :fleet, game:, country: country_fra) }
        let(:ven_up) { build(:unit_position, unit: ven_u, turn:, territory: t_ven) }
        let(:orders) do
          super().merge(
            # FRA F Tun -> TYS
            tun: build(:intended_order, :move, turn:, unit: tun_u, unit_position: tun_up, from_territory: t_tun, to_territory: t_tys, country: country_fra),
            # FRA F Ven -> Apu
            ven: build(:intended_order, :move, turn:, unit: ven_u, unit_position: ven_up, from_territory: t_ven, to_territory: t_apu, country: country_fra)
          )
        end

        it 'returns 1' do
          expect(subject).to eq 1
        end
      end
    end
  end

  describe '#support_cut?' do
    subject { ios.support_cut?(at: supporting_territory, country: country_ita) }

    let(:supporting_territory) { t_apu }
    let(:nap_up) { build(:unit_position, turn:, country: country_ita, territory: t_nap) }
    let(:apu_up) { build(:unit_position, turn:, country: country_ita, territory: t_apu) }
    let(:orders) do
      {
        # F Nap H
        nap: build(:intended_order, :hold, turn:, unit_position: nap_up, from_territory: t_nap),
        # F Apu (S) F Nap H
        apu: build(:intended_order, :support_hold, turn:, unit_position: apu_up, from_territory: t_nap, to_territory: t_nap, assistance_territory: t_apu)
      }
    end

    context 'when there is no support from the specified territory' do
      let(:supporting_territory) { t_ion }

      it { is_expected.to be_falsey }
    end

    context 'when support is not cut' do
      let(:supporting_territory) { t_apu }

      it { is_expected.to be_falsey }
    end

    context 'when support is cut' do
      let(:supporting_territory) { t_apu }
      let(:ion_up) { build(:unit_position, turn:, country: country_fra, territory: t_ion) }
      let(:orders) do
        super().merge(
          # FRA F Ion -> Apu
          ion: build(:intended_order, :move, turn:, unit_position: ion_up, to_territory: t_apu)
        )
      end

      it { is_expected.to be_truthy }
    end
  end
end
