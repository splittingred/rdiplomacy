# frozen_string_literal: true

module Orders
  class IntendedOrderValidator
    include ::Dry::Monads[:result]

    ##
    # @param [IntendedOrder] order
    # @return [Success<order>]
    # @return [Failure<ActiveModel::Errors>]
    #
    def call(order:)
      errors = ::ActiveModel::Errors.new(order)
      errors.add(:base, 'Order is not valid') unless order.valid?

      case order.move_type
      when Order::TYPE_HOLD
        # holds always succeed, no-op here
      when Order::TYPE_MOVE
        validate_move(order:, errors:)
      when Order::TYPE_SUPPORT_HOLD
        validate_support_hold(order:, errors:)
      when Order::TYPE_SUPPORT_MOVE
        validate_support_move(order:, errors:)
      when Order::TYPE_CONVOY
        validate_support_convoy(order:, errors:)
      else
        errors.add(:base, 'Order type is not valid')
      end
      errors.any? ? Failure(errors) : Success(order)
    end

    private

    ##
    # @param [IntendedOrder] order
    # @param [ActiveModel::Errors] errors
    # @return [Boolean]
    #
    def validate_move(order:, errors:)
      return true if order.unit.can_move_to?(order.to_territory)

      order.invalidate!
      errors.add(:base, 'Unit cannot move to that territory')
      false
    end

    ##
    # @param [IntendedOrder] order
    # @param [ActiveModel::Errors] errors
    # @return [Boolean]
    #
    def validate_support_hold(order:, errors:)
      return true if order.unit.can_support_hold?(order.to_territory)

      order.invalidate!
      errors.add(:base, 'Unit cannot support that territory')
      false
    end

    ##
    # @param [IntendedOrder] order
    # @param [ActiveModel::Errors] errors
    # @return [Boolean]
    #
    def validate_support_move(order:, errors:)
      return true if order.unit.can_support_move?(from_territory: order.from_territory, to_territory: order.to_territory)

      order.invalidate!
      errors.add(:base, 'Unit cannot support that territory to move there')
      false
    end

    ##
    # @param [IntendedOrder] order
    # @param [ActiveModel::Errors] errors
    # @return [Boolean]
    #
    def validate_support_convoy(order:, errors:)
      return true if order.unit.can_convoy?(from_territory: order.from_territory, to_territory: order.to_territory)

      order.invalidate!
      errors.add(:base, 'Unit cannot convoy that unit to that territory')
      false
    end
  end
end
