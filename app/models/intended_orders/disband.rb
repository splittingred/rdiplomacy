# frozen_string_literal: true

module IntendedOrders
  class Disband < IntendedOrder
    ##
    # @return [String]
    #
    def to_s(country_prefix: false)
      country_prefix = country_prefix ? "#{country.to_s.upcase} " : ''
      "#{country_prefix}#{unit} #{from_territory}"
    end

    ##
    # @param [Entities::IntendedOrders] orders
    # @return [Boolean]
    #
    def validate!(orders:)
      # TODO: handle disbanding
      super
    end
  end
end
