# frozen_string_literal: true

module Games
  module Commands
    module Adjudicate
      class Request < ::RDiplomacy::Request
        # @!attribute game
        #   @return [Game]
        attribute(:game, ::Types.Instance(::Game))
        # @!attribute turn
        #   @return [Turn]
        attribute(:turn, ::Types.Instance(::Turn))
      end
    end
  end
end
