# frozen_string_literal: true

module Maps
  class ConvoyGraph < ::RGL::DirectedAdjacencyGraph
    ##
    # Is a unit convoyable from one territory to another?
    #
    # @param [String|Territory] from
    # @param [String|Territory] to
    #
    def convoyable?(from:, to:)
      from_abbr = from.is_a?(Territory) ? from.abbr : from.to_s
      to_abbr = to.is_a?(Territory) ? to.abbr : to.to_s
      path?(from_abbr, to_abbr)
    end
  end
end
