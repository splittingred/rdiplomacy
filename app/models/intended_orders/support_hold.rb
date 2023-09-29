# frozen_string_literal: true

module IntendedOrders
  class SupportHold < IntendedOrder
    ##
    # @return [String]
    #
    def to_s(country_prefix: false)
      country_prefix = country_prefix ? "#{country.to_s.upcase} " : ''
      supported_country_prefix = '' # TODO: Add country prefix for multi-country supports
      "#{country_prefix}#{unit} #{assistance_territory} S #{supported_country_prefix}#{from_territory} H"
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
        fail!(:assistance_territory, :unit_dislodged, 'Cannot support a hold with a dislodged unit')
      elsif supported_order.unit_position.dislodged?
        fail!(:assistance_territory, :supported_unit_dislodged, 'Cannot support a dislodged unit')
      elsif !orders.territory_occupied?(from_territory)
        fail!(:to_territory, :no_unit_at_supported_territory, 'Cannot support a hold where no unit exists')
      elsif orders.support_cut?(at: assistance_territory, country: country)
        fail!(:from_territory, :support_cut, 'Support cut')
      elsif to_territory.abbr != supported_order.to_territory.abbr
        fail!(:to_territory, :supported_unit_moved, 'Supported unit moved elsewhere')
      elsif !from_territory.can_be_occupied_by?(unit)
        fail!(:from_territory, :invalid_unit_type, "#{unit.unit_type} cannot support a hold in a territory it cannot move to")
      else
        super
      end
    end
  end
end
