# frozen_string_literal: true

module Orders
  class AdjudicationService
    include ::Dry::Monads[:result]
    include ::Dry::Monads::Result.for(:adjudicate)
    # @!attribute [r] logger
    #   @return [Logger]
    include ::Rdiplomacy::Deps[
      logger: 'logger'
    ]

    ##
    # @param [Entities::IntendedOrders] orders
    # @return [Success<Entities::IntendedOrders>]
    #
    def call(orders)
      orders.each do |order|
        adjudicate(orders:, order:)
      end
      Success(orders)
    end

    private

    def adjudicate(orders:, order:)
      case order.move_type
      when Order::TYPE_HOLD
        yield adjudicate_hold(order:)
      when Order::TYPE_MOVE
        yield adjudicate_move(orders:, order:)
      when Order::TYPE_RETREAT
        yield adjudicate_retreat(orders:, order:)
      when Order::TYPE_SUPPORT_HOLD
        yield adjudicate_support_hold(orders:, order:)
      when Order::TYPE_SUPPORT_MOVE
        yield adjudicate_support_move(orders:, order:)
      when Order::TYPE_CONVOY
        yield adjudicate_convoy(orders:, order:)
      when Order::TYPE_BUILD
        yield adjudicate_build(orders:, order:)
      when Order::TYPE_DISBAND
        yield adjudicate_disband(orders:, order:)
      else
        logger.error "Order #{order} is an invalid move type"
        # no-op, invalid move type
      end
    end

    ##
    # @param [IntendedOrder] order
    #
    def adjudicate_hold(order:)
      fail_order!(order, :invalid_order, 'Cannot hold a dislodged unit') if order.unit_position.dislodged?

      # Holds always "succeed" at the adjudication stage. The unit may be dislodged later if the unit is overpowered
      # during the resolution stage. However, this is still a "successful" order.
      order.succeed!
      Success(order)
    end

    ##
    # @param [IntendedOrder] order
    #
    def adjudicate_move(orders:, order:)
      # Calculate the strength of the move, and determine if it was the "winning" move
      fail_order!(order, :move_failed, 'Move failed') unless orders.successful_move_order_to(order.to_territory) == order

      order.succeed!
      Success(order)
    end

    ##
    # @param [IntendedOrder] order
    #
    def adjudicate_retreat(orders:, order:)
      fail_order!(order, :invalid_order, 'Cannot retreat a unit that is not dislodged') unless order.unit_position.dislodged?

      # TODO: Handle retreats
      Success(order)
    end

    ##
    # @param [IntendedOrder] order
    #
    def adjudicate_support_hold(orders:, order:)
      fail_order!(order, :support_cut, 'Support cut') if orders.support_cut_at?(order.from_territory)

      order.succeed!
      Success(order)
    end

    ##
    # @param [IntendedOrder] order
    #
    def adjudicate_support_move(orders:, order:)
      fail_order!(order, :support_cut, 'Support cut') if orders.support_cut_at?(order.from_territory)

      order.succeed!
      Success(order)
    end

    ##
    # @param [IntendedOrder] order
    #
    def adjudicate_convoy(orders:, order:)
      # TODO: handle convoys
      Success(order)
    end

    ##
    # @param [IntendedOrder] order
    #
    def adjudicate_build(orders:, order:)
      # TODO: handle builds
      Success(order)
    end

    ##
    # @param [IntendedOrder] order
    #
    def adjudicate_disband(orders:, order:)
      # TODO: handle disbands
      Success(order)
    end

    ##
    # @param [IntendedOrder] order
    # @param [Symbol] code
    # @param [String] message
    #
    def fail_order!(order, code, message)
      order.fail!(code:, message:)
      Failure(Error.new(code:, message:))
    end
  end
end
