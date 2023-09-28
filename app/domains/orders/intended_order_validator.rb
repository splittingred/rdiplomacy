# frozen_string_literal: true

module Orders
  class IntendedOrderValidator
    include ::Dry::Monads[:result]

    ##
    # @param [IntendedOrder] order
    # @return [Success<IntendedOrder>]
    # @return [Failure<Error>]
    #
    def call(order:)
      case order.move_type
      when Order::TYPE_HOLD
        # holds always succeed, no-op here
      when Order::TYPE_MOVE
        validate_move(order)
      when Order::TYPE_SUPPORT_HOLD
        validate_support_hold(order)
      when Order::TYPE_SUPPORT_MOVE
        validate_support_move(order)
      when Order::TYPE_CONVOY
        validate_support_convoy(order)
      else
        order.invalidate!(code: :move_type, message: 'Order type is not valid')
      end

      return Failure(Error.new(code: :invalid_order, message: "Invalid order: #{order.errors.full_messages.join(', ')}")) if order.invalid?

      order.validate!
      Success(order)
    end

    private

    ##
    # @param [IntendedOrder] order
    # @return [Boolean]
    #
    def validate_move(order)
      return true if order.valid_move?

      order.invalidate!(code: :to_territory, message: 'Unit cannot move to that territory')
      false
    end

    ##
    # @param [IntendedOrder] order
    # @return [Boolean]
    #
    def validate_support_hold(order)
      return true if order.unit.can_support_hold_at?(at: order.to_territory, turn: order.turn)

      order.invalidate!(code: :to_territory, message: 'Unit cannot support that territory')
      false
    end

    ##
    # @param [IntendedOrder] order
    # @return [Boolean]
    #
    def validate_support_move(order)
      return true if order.unit.can_support_move_to?(to: order.to_territory, turn: order.turn)

      order.invalidate!(code: :to_territory, message: 'Unit cannot support that territory')
      false
    end

    ##
    # @param [IntendedOrder] order
    # @return [Boolean]
    #
    def validate_support_convoy(order)
      return true if order.unit.can_convoy?(from: order.from_territory, to: order.to_territory, turn: order.turn)

      order.invalidate!(code: :to_territory, message: 'Unit cannot convoy that unit to that territory')
      false
    end
  end
end
