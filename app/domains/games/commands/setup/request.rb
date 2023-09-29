# frozen_string_literal: true

module Games
  module Commands
    module Setup
      class Request < ::RDiplomacy::Request
        # @!attribute name
        #   @return [String] The name of the game
        attribute(:name, ::Types::String)
        # @!attribute variant_abbr
        #   @return [String] The abbreviation of the variant to setup
        attribute(:variant_abbr, ::Types::String)
        # @!attribute map_abbr
        #   @return [String] The abbreviation of the map to use
        attribute(:map_abbr, ::Types::String)
        # @!attribute exclusive
        #   @return [Boolean] True if to find the game with the same name, and idempotently setup the game
        attribute(:exclusive, ::Types::Bool.default(false))
      end
    end
  end
end
