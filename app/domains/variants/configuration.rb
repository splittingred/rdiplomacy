# frozen_string_literal: true

module Variants
  class Configuration < ::Entities::Base
    ##
    # Represents a country in a variant
    #
    class Country < ::Entities::Base
      ##
      # Represents a starting unit for a country for a variant
      #
      class StartingUnit < ::Entities::Base
        # @!attribute type
        #   @return [String]
        attribute(:type, ::Types::Coercible::String.default('army'))
        # @!attribute territory
        #   @return [String]
        attribute(:territory, ::Types::Coercible::String.default(''))
        # @!attribute coast
        #   @return [Boolean]
        attribute(:coast, ::Types::Coercible::Bool.default(false))

        ##
        # @return [String]
        #
        def territory_full_abbr
          coast? ? "#{territory}-#{coast}" : territory
        end

        ##
        # @return [Boolean]
        #
        def army?
          type == 'army'
        end

        ##
        # @return [Boolean]
        #
        def fleet?
          type == 'fleet'
        end

        ##
        # @return [Boolean]
        #
        def coast?
          coast.present?
        end
      end

      # @!attribute name
      #   @return [String]
      attribute(:name, ::Types::Coercible::String.default(''))
      # @!attribute abbr
      #   @return [String]
      attribute(:abbr, ::Types::Coercible::String.default(''))
      # @!attribute possessive
      #   @return [String]
      attribute(:possessive, ::Types::Coercible::String.default(''))
      # @!attribute color
      #   @return [String]
      attribute(:color, ::Types::Coercible::String.default(''))
      # @!attribute starting_influence
      #    @return [Array<String>]
      attribute(:starting_influence, ::Types::Array.of(::Types::Coercible::String).default { [] })
      # @!attribute starting_units
      #   @return [Array<StartingUnit>]
      attribute(:starting_units, ::Types::Array.of(Object).default { [] })
    end

    ##
    # Represents the types of allowed moves for this variant
    #
    class MoveType < ::Entities::Base
      # @!attribute name
      #   @return [String]
      attribute(:name, ::Types::Coercible::String.default(''))
      # @!attribute width
      #   @return [Integer]
      attribute(:width, ::Types::Coercible::Integer.default(0))
      # @!attribute height
      #   @return [Integer]
      attribute(:height, ::Types::Coercible::Integer.default(0))
    end

    class Opts < ::Entities::Base
      # @!attribute start_year
      #   @return [Integer]
      attribute(:start_year, ::Types::Coercible::Integer.default(1901))
      # @!attribute start_season
      #   @return [String]
      attribute(:start_season, ::Types::Coercible::String.default('SPRING'))
      # @!attribute turn_length
      #   @return [Integer]
      attribute(:turn_length, ::Types::Coercible::Integer.default(86_400))
    end

    class Season < ::Entities::Base
      # @!attribute name
      #   @return [String]
      attribute(:name, ::Types::Coercible::String.default(''))
      # @!attribute abbr
      #   @return [String]
      attribute(:abbr, ::Types::Coercible::String.default(''))
      # @!attribute next
      #   @return [String]
      attribute(:next, ::Types::Coercible::String.default(''))
      # @!attribute moves_allowed
      #   @return [Boolean]
      attribute(:moves_allowed, ::Types::Bool.default(true))
      # @!attribute reconcile_units
      #   @return [Boolean]
      attribute(:reconcile_units, ::Types::Bool.default(false))
      # @!attribute end_of_year
      #   @return [Boolean]
      attribute(:end_of_year, ::Types::Bool.default(false))

      def end_of_year?
        end_of_year == true
      end
    end

    # @!attribute name
    #   @return [String]
    attribute(:name, ::Types::Coercible::String.default(''))
    # @!attribute description
    #   @return [String]
    attribute(:description, ::Types::Coercible::String.default(''))
    # @!attribute map
    #   @return [String]
    attribute(:map, ::Types::Coercible::String.default('classic'))
    # @!attribute opts
    #   @return [Opts]
    attribute(:opts, ::Types.Instance(Object))
    # @!attribute countries
    #   @return [Hash<Symbol,Country>]
    attribute(:countries, ::Types::Hash.default { {} })
    # @!attribute move_types
    #   @return [Hash<Symbol,MoveType>]
    attribute(:move_types, ::Types::Hash.default { {} })
    # @!attribute seasons
    #   @return [Hash<Symbol,Season>]
    attribute(:seasons, ::Types::Hash.default { {} })
  end
end
