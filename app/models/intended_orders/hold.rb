# frozen_string_literal: true

module IntendedOrders
  class Hold < IntendedOrder
    ##
    # @return [String]
    #
    def to_s(country_prefix: false)
      country_prefix = country_prefix ? "#{country.to_s.upcase} " : ''
      "#{country_prefix}#{unit} #{from_territory} H"
    end

    ##
    # Holds always "succeed" at the validation stage if not dislodged. The unit may be dislodged later if the unit is
    # overpowered during the resolution stage. However, this is still a "successful" order.
    #
    # @param [Entities::IntendedOrders] orders
    # @return [Boolean]
    #
    def validate!(orders:)
      if unit_dislodged?
        fail!(:from_territory, :unit_dislodged, 'Cannot hold a dislodged unit')
      else
        super
      end
    end
  end
end
