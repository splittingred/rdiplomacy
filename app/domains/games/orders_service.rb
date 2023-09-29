# frozen_string_literal: true

module Games
  class OrdersService
    include ::Dry::Monads[:result]

    ##
    # @param [Games::Turn] turn
    # @return [Success<Entities::OrderRegister>]
    # @return [Failure<Error>]
    #
    def find_register(turn:)
      game = turn.game
      register = ::Entities::OrderRegister.new(
        game_id: game.id,
        variant_id: game.variant_id
      )
      country_orders = {}

      q = build_find_query(game:, turn:)
      q.each do |order|
        country_orders[order.country_abbr.to_sym] ||= []
        country_orders[order.country_abbr.to_sym] << ::Entities::OrderRegister::CountryOrder.new(
          country_abbr: order.country_abbr.to_s,
          country_name: order.country_name.to_s,
          unit_territory_abbr: order.unit_territory_abbr.to_s,
          unit_type: order.unit_type || Unit::TYPE_ARMY,
          move_type: order.move_type || Order::TYPE_HOLD,
          from_territory_abbr: order.from_territory_abbr || '',
          to_territory_abbr: order.to_territory_abbr || '',
          assisting_territory_abbr: order.assistance_territory_abbr || '',
          order_string: order.to_s # TODO: needs to be optimized - still uses AREL, not sure how to safely do this yet
        )
      end
      register.turn = ::Entities::OrderRegister::Turn.new(
        year: turn.year.to_i,
        season: turn.season.to_s,
        current: turn.current?
      )
      register.countries = country_orders
      Success(register)
    end

    private

    # TODO: Does this need to handle orders that are not yet submitted?
    def build_find_query(game:, turn:)
      ::Order
        .for_game(game)
        .on_turn(turn)
        .left_joins(country: [], unit_position: %i[territory unit], from_territory: [], to_territory: [], assistance_territory: [])
        .select('
          orders.*,
          units.unit_type AS unit_type,
          territories.abbr AS unit_territory_abbr,
          from_territories_orders.abbr AS from_territory_abbr,
          to_territories_orders.abbr AS to_territory_abbr,
          assistance_territories_orders.abbr AS assistance_territory_abbr,
          countries.name AS country_name,
          countries.abbr AS country_abbr
        ').order('countries.name ASC')
    end
  end
end
