# frozen_string_literal: true

module IntendedOrders
  class Move < IntendedOrder
    ##
    # @return [String]
    #
    def to_s(country_prefix: false)
      country_prefix = country_prefix ? "#{country.to_s.upcase} " : ''
      "#{country_prefix}#{unit} #{from_territory} - #{to_territory}"
    end

    ##
    # can this unit physically move to the location it's trying to move to?
    #
    def valid_destination?
      from_territory.adjacent_to?(to_territory) && to_territory.can_be_occupied_by?(unit)
    end

    ##
    # Calculate the strength of the move, and determine if it was the "winning" move
    #
    # @param [Entities::IntendedOrders] orders
    # @return [Boolean]
    #
    def validate!(orders:)
      if unit_dislodged?
        fail!(:from_territory, :unit_dislodged, 'Cannot move a dislodged unit')
      elsif !convoyed && !valid_destination?
        # if the unit is not being convoyed, it must be adjacent to the destination
        fail!(:to_territory, :invalid_move, 'Unit cannot move to that territory')
      # elsif convoyed && false
      #   # TODO: handle convoy pathing checks
      elsif orders.winning_move_order_to(to_territory) != self
        fail!(:to_territory, :move_failed, 'Move failed')
      else
        super
      end
    end
  end
end
