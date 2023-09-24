# frozen_string_literal: true

module Views
  class GameMapView < ::RDiplomacy::View
    # @!attribute [r] game
    #   @return [Game]
    attr_reader :game
    # @!attribute [r] map
    #   @return [Map]
    attr_reader :map
    # @!attribute [r] turn
    #   @return [Turn]
    attr_reader :turn
    # @!attribute [r] orders
    #   @return [Entities::OrderRegister]
    attr_reader :orders
    # @!attribute [r] units
    #   @return [Hash<Symbol,Hash>]
    attr_reader :units
    # @!attribute [r] territories
    #   @return [Hash<Symbol,Hash>]
    attr_reader :territories

    ##
    # @param [Integer] game_id
    # @param [Integer|NilClass] year
    # @param [String|NilClass] season
    #
    def initialize(game_id:, year: 1901, season: 'SPRING')
      @game_id = game_id.to_i
      @year = year.to_i
      @season = season.to_s
      super
    end

    ##
    # Render the view
    #
    # @return [Success<GameMapView>]
    # @return [Failure<Error>]
    #
    def call
      @game = yield find_game(@game_id)
      @turn = yield find_turn(game: @game, year: @year, season: @season)
      @map = yield render_map(game: @game)
      @orders = yield load_order_register(game: @game, turn: @turn)
      @units = yield load_units(game: @game, turn: @turn)
      @territories = yield load_territories(game: @game)
      Success(self)
    end

    private

    ##
    # @param [Integer] game_id
    # @return [Success<Game>]
    # @return [Failure<Error>]
    #
    def find_game(game_id)
      container['games.service'].find(game_id)
    end

    ##
    # @param [Game] game
    # @param [Integer] year
    # @param [String] season
    # @return [Success<Turn>]
    # @return [Failure<Error>]
    #
    def find_turn(game:, year: nil, season: nil)
      q = ::Turn.for_game(game)
      q = year.present? || season.nil? ? q.current : q.by_season(season).by_year(year)
      Success(q.first!)
    end

    ##
    # @param [Game] game
    # @param [Turn] turn
    # @return [Success<Entities::OrderRegister>]
    # @return [Failure<Error>]
    #
    def load_order_register(game:, turn:)
      container['games.orders_service'].find_register(game:, turn:)
    end

    ##
    # @param [Game] game
    # @return [Success<Map>]
    # @return [Failure<Error>]
    #
    def render_map(game:)
      container['games.map_rendering_service'].render(game:, turn: game.current_turn)
    end

    ##
    # @param [Game] game
    # @param [Turn] turn
    # @return [Success<Hash>]
    # @return [Failure<Error>]
    #
    def load_units(game:, turn:)
      map_config = game.map.configuration
      positions = ::UnitPosition
                  .joins(unit: [:country], territory: [])
                  .on_turn(turn)
                  .select('unit_positions.*, units.unit_type, countries.abbr AS country_abbr, countries.color AS country_color, territories.abbr AS unit_territory_abbr')
      Success(
        positions.each_with_object({}) do |co, units|
          unit_type = map_config.unit_type(co.unit_type)
          # TODO: Handle dislodged units in same place
          units[co.unit_territory_abbr.to_sym] = {
            country_abbr: co.country_abbr,
            country_color: co.country_color,
            unit_type: co.unit_type,
            unit_width: unit_type.width,
            unit_height: unit_type.height,
            unit_territory_abbr: co.unit_territory_abbr,
            unit_territory_x: map_config.unit_x(co.unit_territory_abbr),
            unit_territory_y: map_config.unit_y(co.unit_territory_abbr)
          }
        end
      )
    end

    def load_territories(game:)
      Success(
        game.variant.territories.each_with_object({}) do |t, territories|
          territories[t.abbr.to_sym] = {
            name: t.name,
            abbr: t.abbr,
            geographical_type: t.geographical_type,
            supply_center: t.supply_center?,
            parent_territory_abbr: t.parent_territory&.abbr || '',
            coast: t.coast?,
            unit_x: t.unit_x,
            unit_y: t.unit_y,
            unit_dislodged_x: t.unit_dislodged_x,
            unit_dislodged_y: t.unit_dislodged_y
          }
        end
      )
    end
  end
end
