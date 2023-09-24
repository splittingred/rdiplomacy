# frozen_string_literal: true

describe Games::Order do
  let(:variant) { build(:variant) }
  let(:game) { build(:game, variant:) }
  let(:turn_1) { build(:turn, :S1901, game:) }
  let(:country_ita) { build(:country, :italy, game:) }
  let(:player_1) { build(:player, game:, country: country_ita) }
  let(:from_territory) { build(:territory, :nap, variant:) }
  let(:to_territory) { build(:territory, :ion, variant:) }
  let(:unit_f_nap) { build(:unit, :fleet, game:, country: country_ita) }
  let(:unit_f_nap_pos) { build(:unit_position, unit: unit_f_nap, turn: turn_1, territory: from_territory) }
  let(:order_attributes) { { game:, turn: turn_1, player: player_1, country: country_ita, unit_position: unit_f_nap_pos, from_territory: } }
  let(:order) { build(:order, **order_attributes) }

  describe '#to_s' do
    subject { order.to_s }

    context 'when a move order' do
      let(:order_attributes) { super().merge(move_type: 'move', to_territory:) }

      it 'returns the correct string' do
        expect(subject).to eq('F Nap - Ion')
      end
    end

    context 'when a hold order' do
      let(:order_attributes) { super().merge(move_type: 'hold', to_territory: from_territory) }

      it 'returns the correct string' do
        expect(subject).to eq('F Nap H')
      end
    end

    context 'when a support hold order' do
      let(:territory_to_support) { build(:territory, :aeg, variant:) }
      let(:unit_f_aeg) { build(:unit, :fleet, game:, country: country_ita) }
      let(:unit_f_aeg_pos) { build(:unit_position, unit: unit_f_aeg, turn: turn_1, territory: territory_to_support) }
      let(:order_attributes) { super().merge(move_type: 'support-hold', assistance_territory: from_territory, from_territory: territory_to_support, to_territory: territory_to_support) }

      it 'returns the correct string' do
        expect(subject).to eq('F Nap S Aeg H')
      end
    end

    context 'when a support move order' do
      let(:territory_to_support_from) { build(:territory, :aeg, variant:) }
      let(:territory_to_support_to) { build(:territory, :eas, variant:) }
      let(:unit_f_aeg) { build(:unit, :fleet, game:, country: country_ita) }
      let(:unit_f_aeg_pos) { build(:unit_position, unit: unit_f_aeg, turn: turn_1, territory: territory_to_support_from) }
      let(:order_attributes) { super().merge(move_type: 'support-move', assistance_territory: from_territory, from_territory: territory_to_support_from, to_territory: territory_to_support_to) }

      it 'returns the correct string' do
        expect(subject).to eq('F Nap S Aeg - Eas')
      end
    end

    context 'when a convoy order' do
      let(:territory_to_support_from) { build(:territory, :tun, variant:) }
      let(:territory_to_support_to) { build(:territory, :gre, variant:) }
      let(:unit_a_tun) { build(:unit, :army, game:, country: country_ita) }
      let(:unit_a_tun_pos) { build(:unit_position, unit: unit_a_tun, turn: turn_1, territory: territory_to_support_from) }
      let(:order_attributes) { super().merge(move_type: 'convoy', assistance_territory: from_territory, from_territory: territory_to_support_from, to_territory: territory_to_support_to) }

      it 'returns the correct string' do
        expect(subject).to eq('F Nap C Tun - Gre')
      end
    end
  end
end
