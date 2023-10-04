# frozen_string_literal: true

module IntendedOrders
  class SupportMove < IntendedOrder
    ##
    # @return [String]
    #
    def to_s(country_prefix: nil)
      country_prefix = country_prefix ? "#{country.to_s.upcase} " : ''
      supported_country_prefix = '' # TODO: Add country prefix for multi-country supports
      "#{country_prefix}#{unit} #{assistance_territory} S #{supported_country_prefix}#{from_territory} - #{to_territory}"
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
        fail!(:from_territory, :unit_dislodged, 'Cannot support a move with a dislodged unit')
      elsif supported_order.unit_position.dislodged?
        fail!(:assistance_territory, :supported_unit_dislodged, 'Cannot support a dislodged unit')
      elsif orders.support_cut?(at: assistance_territory, country: country)
        fail!(:from_territory, :support_cut, 'Support cut')
      elsif !to_territory.can_be_occupied_by?(unit)
        fail!(:to_territory, :invalid_unit_type, "#{unit.unit_type} cannot support a move to a territory it cannot move to")
      elsif to_territory.abbr != supported_order.to_territory.abbr
        fail!(:to_territory, :supported_unit_moved_elsewhere, "Supported unit attempted to move to #{supported_order.to_territory.abbr} instead of #{to_territory.abbr}")
      else
        super
      end
    end
  end
end
