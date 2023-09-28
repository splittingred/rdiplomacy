# frozen_string_literal: true

module Orders
  class AdjudicationService
    include ::Dry::Monads[:result, :do]
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
      # @type [IntendedOrder] order
      orders.each do |order|
        adjudicate(orders:, order:) if order.valid?
      end
      Success(orders)
    end

    private

    ##
    # @param [Entities::IntendedOrders] orders
    # @param [IntendedOrder] order
    # @return [Success<IntendedOrder>]
    #
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
      Success(order)
    end

    ##
    # @param [IntendedOrder] order
    #
    def adjudicate_hold(order:)
      if order.unit_dislodged?
        order.fail!(:from_territory, :unit_dislodged, 'Cannot hold a dislodged unit')
      else
        # Holds always "succeed" at the adjudication stage. The unit may be dislodged later if the unit is overpowered
        # during the resolution stage. However, this is still a "successful" order.
        order.succeed!
      end
      Success(order)
    end

    ##
    # Calculate the strength of the move, and determine if it was the "winning" move
    #
    # @param [Entities::IntendedOrders] orders
    # @param [IntendedOrder] order
    #
    def adjudicate_move(orders:, order:)
      if order.unit_dislodged?
        order.fail!(:from_territory, :unit_dislodged, 'Cannot move a dislodged unit')
      elsif orders.successful_move_order_to(order.to_territory) == order
        order.succeed!
      else
        order.fail!(:to_territory, :move_failed, 'Move failed')
      end
      Success(order)
    end

    ##
    # @param [Entities::IntendedOrders] orders
    # @param [IntendedOrder] order
    #
    def adjudicate_support_hold(orders:, order:)
      if order.unit_dislodged?
        order.fail!(:from_territory, :unit_dislodged, 'Cannot support a hold with a dislodged unit')
      elsif !orders.territory_occupied?(order.from_territory)
        order.fail!(:to_territory, :no_unit_at_supported_territory, 'Cannot support a hold where no unit exists')
      elsif orders.support_cut?(at: order.assistance_territory, country: order.country)
        order.fail!(:from_territory, :support_cut, 'Support cut')
      elsif !order.from_territory.can_be_occupied_by?(order.unit)
        order.fail!(:from_territory, :invalid_unit_type, "#{order.unit.unit_type} cannot support a hold in a territory it cannot move to")
      else
        order.succeed!
      end
      Success(order)
    end

    ##
    # @param [Entities::IntendedOrders] orders
    # @param [IntendedOrder] order
    #
    def adjudicate_support_move(orders:, order:)
      supported_order = orders.from(order.from_territory)
      if supported_order.nil?
        order.fail!(:from_territory, :no_unit_at_supported_territory, 'Cannot support a move where no unit exists')
      elsif order.unit_dislodged?
        order.fail!(:from_territory, :unit_dislodged, 'Cannot support a move with a dislodged unit')
      elsif orders.support_cut?(at: order.assistance_territory, country: order.country)
        order.fail!(:from_territory, :support_cut, 'Support cut')
      elsif !order.to_territory.can_be_occupied_by?(order.unit)
        order.fail!(:to_territory, :invalid_unit_type, "#{order.unit.unit_type} cannot support a move to a territory it cannot move to")
      elsif order.to_territory.abbr != supported_order.to_territory.abbr
        order.fail!(:to_territory, :supported_unit_moved_elsewhere, "Supported unit attempted to move to #{supported_order.to_territory.abbr} instead of #{order.to_territory.abbr}")
      else
        order.succeed!
      end
      Success(order)
    end

    ##
    # @param [Entities::IntendedOrders] orders
    # @param [IntendedOrder] order
    #
    def adjudicate_convoy(orders:, order:)
      if order.unit_dislodged?
        order.fail!(:from_territory, :unit_dislodged, 'Cannot convoy with a dislodged unit')
      else
        # TODO: handle convoys
        order.succeed!
      end
      Success(order)
    end

    ##
    # @param [Entities::IntendedOrders] orders
    # @param [IntendedOrder] order
    #
    def adjudicate_retreat(orders:, order:)
      if order.unit_dislodged?
        # TODO: Handle retreats
      else
        order.fail!(:from_territory, :invalid_order, 'Cannot retreat a unit that is not dislodged')
      end
      Success(order)
    end

    ##
    # @param [Entities::IntendedOrders] orders
    # @param [IntendedOrder] order
    #
    def adjudicate_build(orders:, order:)
      # TODO: handle builds
      Success(order)
    end

    ##
    # @param [Entities::IntendedOrders] orders
    # @param [IntendedOrder] order
    #
    def adjudicate_disband(orders:, order:)
      # TODO: handle disbands
      Success(order)
    end
  end
end
