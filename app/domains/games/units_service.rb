# frozen_string_literal: true

module Games
  class UnitsService
    def for_turn(turn:)
      ::Unit
        .for_game(turn.game)
        .joins(
          unit_positions: [:territory],
          country: []
        )
        .where(unit_positions: { turn: })
        .select('units.*, territories.abbr AS territory, territories.coast, countries.abbr AS country_abbr')
    end
  end
end
