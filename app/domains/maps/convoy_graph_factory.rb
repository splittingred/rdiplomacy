# frozen_string_literal: true

module Maps
  class ConvoyGraphFactory
    ##
    # Build a convoy graph from a given turn, showing all the possible convoy paths.
    #
    # @param [Turn] turn
    # @return [RGL::AdjacencyGraph]
    #
    # TODO: multi-fleet convoys. Need to get better test data to simulate this
    #
    def build_for_turn(turn:)
      # we use a directed to graph to represent the convoy graph from army to an eventual land position
      graph = ::Maps::ConvoyGraph.new

      occupied = turn.unit_positions.not_dislodged.includes(:territory, :unit).each_with_object({}) do |up, hsh|
        hsh[up.territory.abbr] = up.unit
      end

      territories = turn.game.map.configuration.territories

      territories.each_value do |territory|
        # inland territories can never convoy
        next if territory.inland?

        # we only make vertexes for occupied territories
        next unless occupied.key?(territory.abbr)

        # we only care about root nodes of armies for convoying
        next unless occupied[territory.abbr].army?

        graph.add_vertex(territory.abbr)

        territory.borders.each do |border|
          # if it's not convoyable to, ignore
          next unless border.convoyable_to?

          # if there's no unit in it, ignore
          next unless occupied.key?(border.abbr)

          # we only care about borders that have fleets. we care about armies in the root territories for pathing.
          next unless occupied[border.abbr].fleet?

          graph.add_edge(territory.abbr, border.abbr)
        end
      end

      graph.edges.each do |edge|
        next unless territories.key?(edge.target.to_sym)

        territories[edge.target.to_sym].borders.each do |border|
          next unless border.convoyable_to?

          # if this is a sea and there's no unit in it, ignore
          next if border.sea? && !occupied.key?(border.abbr)

          graph.add_edge(edge.target, border.abbr)
        end
      end
      graph
    end
  end
end
