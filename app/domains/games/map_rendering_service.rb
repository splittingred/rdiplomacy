# frozen_string_literal: true

module Games
  class MapRenderingService
    include ::Dry::Monads[:result]
    # @!attribute [r] units_service
    #   @return [Games::UnitsService]
    include ::Rdiplomacy::Deps[
      units_service: 'games.units_service',
    ]

    ##
    # @param [Games::Game] game
    # @param [Games::Turn] turn
    # @return [Success<Games::Map>]
    # @return [Failure<Error>]
    #
    def render(game:, turn:)
      # @type [Games::Map] map
      map = game.map

      # render units
      units_service.fetch(game:, turn:).each do |unit|
        map.add_unit(territory: unit.territory, country: unit.country_abbr, type: unit.unit_type, coast: unit.coast)
      end

      # render moves
      game.moves.includes(:to_territory, :from_territory, unit: [:country]).on_turn(turn).each do |move|
        case move.move_type
        when 'move'
          map.add_move_order(from: move.from_territory.abbr, to: move.to_territory.abbr, unit_type: move.unit.unit_type, color: move.unit.country.color)
        when 'hold'
          map.add_hold_order(territory: move.from_territory.abbr, unit_type: move.unit.unit_type, color: move.unit.country.color)
        when 'support-move'
          map.add_support_move_order(support: move.assistance_territory.abbr, from: move.from_territory.abbr, to: move.to_territory.abbr, unit_type: move.unit.unit_type, color: move.unit.country.color)
        when 'support-hold'
          map.add_support_hold_order(support: move.assistance_territory.abbr, territory: move.to_territory.abbr, unit_type: move.unit.unit_type, color: move.unit.country.color)
        when 'convoy'
          map.add_convoy_order(convoy: move.assistance_territory.abbr, from: move.from_territory.abbr, to: move.to_territory.abbr, unit_type: move.unit.unit_type, color: move.unit.country.color)
        else
          Failure(::Error.new(code: :unknown_move, message: "Unknown move type: #{move.move_type}"))
        end
        # TODO: disband, build, invalid, retreat, dislodged?
      end
      Success(map)
    end
  end
end
