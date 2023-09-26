# frozen_string_literal: true

describe Entities::IntendedOrders do
  let(:ios) { described_class.new(orders) }

  # TODO: figure out how to lazily generate these via annotations on the describe block
  let(:t_apu) { build(:territory, :apu) }
  let(:t_ion) { build(:territory, :ion) }
  let(:t_nap) { build(:territory, :nap) }
  let(:t_rom) { build(:territory, :rom) }
  let(:t_tus) { build(:territory, :tus) }
  let(:t_ven) { build(:territory, :ven) }
  let(:t_gre) { build(:territory, :gre) }
  let(:t_eas) { build(:territory, :eas) }
  let(:t_adr) { build(:territory, :adr) }
  let(:t_aeg) { build(:territory, :aeg) }
  let(:t_syr) { build(:territory, :syr) }
  let(:t_pie) { build(:territory, :pie) }
  let(:t_tys) { build(:territory, :tys) }
  let(:t_tun) { build(:territory, :tun) }

  let(:country_ita) { build(:country, :italy) }
  let(:country_fra) { build(:country, :france) }
  let(:orders) do
    {
      ven: build(:intended_order, :hold, from_territory: t_ven, country: country_ita), # F VEN H - unsupported hold
      rom: build(:intended_order, :hold, from_territory: t_rom, country: country_ita), # F ROM H - supported hold by ROM
      nap: build(:intended_order, :move, from_territory: t_nap, to_territory: t_ion, country: country_ita), # F NAP - ION
      apu: build(:intended_order, :support_move, assistance_territory: t_apu, from_territory: t_nap, to_territory: t_ion, country: country_ita), # F APU S F NAP - ION
      tus: build(:intended_order, :support_hold, assistance_territory: t_tus, from_territory: t_rom, country: country_ita), # F TUS S F ROM H
      eas: build(:intended_order, :move, from_territory: t_eas, to_territory: t_ion, country: country_ita), # F EAS - ION
      gre: build(:intended_order, :support_move, assistance_territory: t_gre, from_territory: t_eas, to_territory: t_ion, country: country_ita), # F GRE S F EAS - ION
      aeg: build(:intended_order, :support_move, assistance_territory: t_aeg, from_territory: t_eas, to_territory: t_ion, country: country_ita) # F AEG S F EAS - ION
    }
  end

  describe '#successful_move_order_to' do
    subject { ios.successful_move_order_to(t_ion) }

    context 'when there are no competing moves to the territory' do
      let(:orders) do
        {
          nap: build(:intended_order, :move, from_territory: t_nap, to_territory: t_ion, country: country_ita) # F NAP - ION
        }
      end

      it 'returns the same order' do
        expect(subject).to eq(orders[:nap])
      end
    end

    context 'when there are competing moves' do
      let(:orders) do
        {
          nap: build(:intended_order, :move, from_territory: t_nap, to_territory: t_ion, country: country_ita), # ITA F Nap - ION
          tun: build(:intended_order, :move, from_territory: t_tun, to_territory: t_ion, country: country_fra)  # FRA F Tun - ION
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
            apu: build(:intended_order, :support_move, assistance_territory: t_apu, from_territory: t_nap, to_territory: t_ion, country: country_ita) # ITA F Apu (S) F Nap - ION
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
              apu: build(:intended_order, :support_move, assistance_territory: t_apu, from_territory: t_nap, to_territory: t_ion, country: country_ita), # ITA F Apu (S) F Nap - ION
              adr: build(:intended_order, :support_move, assistance_territory: t_adr, from_territory: t_nap, to_territory: t_ion, country: country_ita), # ITA F Adr (S) F Nap - ION
              tys: build(:intended_order, :support_move, assistance_territory: t_tys, from_territory: t_nap, to_territory: t_ion, country: country_fra)  # FRA F Tys (S) F Nap - ION
            )
          end

          it 'returns the winning move' do
            expect(subject).to eq(orders[:nap])
          end
        end

        context 'when the moves are equal in strength' do
          let(:orders) do
            super().merge(
              apu: build(:intended_order, :support_move, assistance_territory: t_apu, from_territory: t_nap, to_territory: t_ion, country: country_ita), # ITA F Apu (S) F Nap - ION
              tys: build(:intended_order, :support_move, assistance_territory: t_tys, from_territory: t_nap, to_territory: t_ion, country: country_fra)  # FRA F Tys (S) F Nap - ION
            )
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

    context 'when the destination has moves to it' do
      let(:destination) { t_ion }
      let(:orders) do
        {
          nap: build(:intended_order, :move, from_territory: t_nap, to_territory: t_ion, country: country_ita), # F NAP - ION
          eas: build(:intended_order, :move, from_territory: t_eas, to_territory: t_ion, country: country_ita) # F EAS - ION
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
          nap: build(:intended_order, :move, from_territory: t_nap, to_territory: t_ion, country: country_ita) # F NAP - ION
        }
      end

      it 'returns zero moves' do
        expect(subject.size).to eq(0)
      end
    end
  end

  describe '#from' do
    subject { ios.from(from) }

    let(:from) { t_nap }
    let(:orders) do
      {
        nap: build(:intended_order, :move, from_territory: t_nap, to_territory: t_ion, country: country_ita), # F NAP - ION
        eas: build(:intended_order, :move, from_territory: t_eas, to_territory: t_ion, country: country_ita) # F EAS - ION
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

    let(:territory) { t_ion }
    let(:orders) do
      {
        nap: build(:intended_order, :hold, from_territory: t_nap, country: country_ita) # F Nap H - supported hold by Rom
      }
    end

    context 'when there is a unit at the territory' do
      let(:territory) { t_nap }

      context 'when the unit is moving' do
        let(:orders) do
          super().merge(
            nap: build(:intended_order, :move, from_territory: t_nap, to_territory: t_ion, country: country_ita) # F Nap -> F Ion
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
          let(:orders) do
            super().merge(
              rom: build(:intended_order, :support_hold, assistance_territory: t_rom, from_territory: t_nap, country: country_ita), # F Rom (S) F Nap H
              ion: build(:intended_order, :support_hold, assistance_territory: t_ion, from_territory: t_nap, country: country_ita) # F ION (S) F Nap H
            )
          end

          context 'when no supports are cut' do
            it 'returns 3' do
              expect(subject).to eq 3
            end
          end

          context 'when one support is cut' do
            let(:orders) do
              super().merge(
                tus: build(:intended_order, :move, from_territory: t_tus, to_territory: t_rom, country: country_fra) # FRA F Tus -> F Rom
              )
            end

            it 'returns 2' do
              expect(subject).to eq 2
            end
          end

          context 'when all support is cut' do
            let(:orders) do
              super().merge(
                tus: build(:intended_order, :move, from_territory: t_tus, to_territory: t_rom, country: country_fra), # FRA F Tus -> F Rom
                tun: build(:intended_order, :move, from_territory: t_tun, to_territory: t_ion, country: country_fra) # FRA F Tun -> F ION
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
    subject { ios.move_strength_to(to: destination, country: country_ita) }

    let(:destination) { t_ion }

    let(:orders) do
      {
        nap: build(:intended_order, :move, from_territory: t_nap, to_territory: t_ion, country: country_ita), # F Nap - ION
      }
    end

    context 'when unit is unsupported' do
      it 'returns 1' do
        expect(subject).to eq 1
      end
    end

    context 'when unit is supported' do
      let(:orders) do
        super().merge(
          tys: build(:intended_order, :support_move, from_territory: t_nap, to_territory: t_ion, assistance_territory: t_tys, country: country_ita), # F TYS (S) F Nap - ION
          apu: build(:intended_order, :support_move, from_territory: t_nap, to_territory: t_ion, assistance_territory: t_apu, country: country_ita) # F Apu (S) F Nap - ION
        )
      end

      context 'when no supports are cut' do
        it 'returns 3' do
          expect(subject).to eq 3
        end
      end

      context 'when one support is cut' do
        let(:orders) do
          super().merge(
            tun: build(:intended_order, :move, from_territory: t_tun, to_territory: t_tys, country: country_fra), # FRA F Tun -> TYS
          )
        end

        it 'returns 2' do
          expect(subject).to eq 2
        end
      end

      context 'when both supports are cut' do
        let(:orders) do
          super().merge(
            tun: build(:intended_order, :move, from_territory: t_tun, to_territory: t_tys, country: country_fra), # FRA F Tun -> TYS
            ven: build(:intended_order, :move, from_territory: t_ven, to_territory: t_apu, country: country_fra) # FRA F Ven -> Apu
          )
        end

        it 'returns 1' do
          expect(subject).to eq 1
        end
      end
    end
  end

  describe '#support_cut?' do
    subject { ios.support_cut?(at: territory, country: country_ita) }

    let(:territory) { t_apu }
    let(:orders) do
      {
        nap: build(:intended_order, :hold, from_territory: t_nap, country: country_ita), # F Nap H
        apu: build(:intended_order, :support_hold, from_territory: t_nap, assistance_territory: t_apu, country: country_ita) # F Apu (S) F Nap H
      }
    end

    context 'when there is no support at the territory' do
      let(:territory) { t_ion }

      it { is_expected.to be_falsey }
    end

    context 'when support is not cut' do
      let(:territory) { t_apu }

      it { is_expected.to be_falsey }
    end

    context 'when support is cut' do
      let(:territory) { t_apu }

      let(:orders) do
        super().merge(
          ion: build(:intended_order, :move, from_territory: t_ion, to_territory: t_apu, country: country_fra) # FRA F Ion -> Apu
        )
      end

      it { is_expected.to be_truthy }
    end
  end
end
