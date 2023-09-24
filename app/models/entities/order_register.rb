# frozen_string_literal: true

module Entities
  class OrderRegister < ::Entities::Base
    ##
    # Represents a given countries orders for a given turn in a game
    #
    class CountryOrder < ::Entities::Base
      # @!attribute country_abbr
      #   @return [String]
      attribute(:country_abbr, ::Types::Strict::String)
      # @!attribute country_name
      #   @return [String]
      attribute(:country_name, ::Types::Strict::String)
      # @!attribute unit_territory_abbr
      #  @return [String]
      attribute(:unit_territory_abbr, ::Types::Strict::String)
      # @!attribute unit_type
      #  @return [String]
      attribute(:unit_type, ::Types::Strict::String)
      # @!attribute move_type
      #  @return [String]
      attribute(:move_type, ::Types::Strict::String)
      # @!attribute from_territory_abbr
      #  @return [String]
      attribute(:from_territory_abbr, ::Types::Strict::String)
      # @!attribute to_territory_abbr
      #  @return [String]
      attribute(:to_territory_abbr, ::Types::Strict::String)
      # @!attribute assistance_territory_abbr
      #  @return [String]
      attribute(:assistance_territory_abbr, ::Types::Strict::String.optional.default { '' })
      # @!attribute order_string
      #  @return [String]
      attribute(:order_string, ::Types::Strict::String)
    end

    ##
    # Represents a given turn for a set of game orders
    #
    class Turn < ::Entities::Base
      # @!attribute year
      #  @return [Integer]
      attribute(:year, ::Types::Strict::Integer)
      # @!attribute season
      #  @return [String]
      attribute(:season, ::Types::Strict::String)
      # @!attribute current
      #  @return [Boolean]
      attribute(:current, ::Types::Bool.optional.default { false })
    end

    # @!attribute game_id
    # @return [Integer]
    attribute(:game_id, ::Types::Strict::Integer)
    # @!attribute variant_id
    # @return [Integer]
    attribute(:variant_id, ::Types::Strict::Integer)
    # @!attribute countries
    #  @return [Hash<Symbol, CountryOrder>]
    attribute(:countries, ::Types::Hash)
    # @!attribute turn
    #  @return [Entities::OrderRegister::Turn]
    attribute(:turn, ::Types.Instance(Object))
  end
end
