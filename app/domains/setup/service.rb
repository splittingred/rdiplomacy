# frozen_string_literal: true

module Setup
  class Service
    include ::Dry::Monads[:result]

    ##
    # @param [Games::Game] game
    # @param [Games::Map] map
    #
    def setup(game:, map:)
      variant = game.variant
      variant.configuration.countries.each_value do |country|
        country.starting_units.each do |unit|
          map.add_unit(territory: unit.territory, country: country.abbr, type: unit.type, coast: unit.coast)
        end
        country.starting_influence.each do |territory|
          map.add_influence(country: country.abbr, territory:)
        end
      end

      map.phase = 'S1901'
      Success()
    end
  end
end
