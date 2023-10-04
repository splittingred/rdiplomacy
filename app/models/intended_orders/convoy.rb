# frozen_string_literal: true

module IntendedOrders
  class Convoy < IntendedOrder
    ##
    # @return [String]
    #
    def to_s(country_prefix: false)
      convoyed_country_prefix = '' # TODO: Add country prefix for multi-country convoys
      "#{country_prefix}#{unit} #{assistance_territory} C #{convoyed_country_prefix}#{from_territory} - #{to_territory}"
    end

    ##
    # @param [Entities::IntendedOrders] orders
    # @return [Boolean]
    #
    def validate!(orders:)
      supported_order = orders.from(from_territory)
      if supported_order.nil?
        fail!(:from_territory, :no_unit_at_supported_territory, 'Cannot support a move where no unit exists')
      elsif unit_dislodged?
        fail!(:from_territory, :unit_dislodged, 'Cannot convoy with a dislodged unit')
      elsif supported_order.unit_position.dislodged?
        fail!(:assistance_territory, :supported_unit_dislodged, 'Cannot support a dislodged unit')
      elsif !unit.can_convoy?(from: from_territory, to: to_territory, turn:)
        fail!(:to_territory, :invalid_convoy, 'Unit cannot convoy that unit to that territory')
      else
        # TODO: handle convoy pathing checks
        super
      end
    end
  end
end
