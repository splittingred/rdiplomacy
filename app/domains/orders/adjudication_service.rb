# frozen_string_literal: true

module Orders
  class AdjudicationService
    include ::Dry::Monads[:result]
    ##
    # @param [Entities::IntendedOrders] orders
    # @return [Success<Entities::IntendedOrders>]
    #
    def call(orders)
      # @type [IntendedOrder] order
      orders.each do |order|
        order.validate!(orders:)
      end
      Success(orders)
    end
  end
end
