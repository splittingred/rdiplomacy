# frozen_string_literal: true

module IntendedOrders
  class Retreat < IntendedOrder
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
    # @param [Entities::IntendedOrders] orders
    # @return [Boolean]
    #
    def validate!(orders:)
      if !valid_destination?
        fail!(:to_territory, :invalid_retreat, 'Unit cannot retreat to that territory')
      elsif unit_dislodged?
        fail!(:from_territory, :invalid_order, 'Cannot retreat a unit that is not dislodged')
      else
        # TODO: Handle retreats
        super
      end
    end
  end
end
