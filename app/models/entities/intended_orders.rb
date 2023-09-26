# frozen_string_literal: true

module Entities
  class IntendedOrders
    include ::Enumerable

    ##
    # @param [Hash{Symbol, IntendedOrder}] orders
    #
    def initialize(orders)
      @orders = orders.with_indifferent_access
      @holds = {}
      @moves = {}
      @support_moves = {}
      @support_holds = {}
      @convoys = {}
      @retreats = {}
      @builds = {}
      @disbands = {}
      categorize(orders)
    end

    ##
    # @yield [IntendedOrder]
    #
    def each(&)
      @orders.each_value(&)
    end

    ##
    # @param [Territory] territory
    # @return [Array<IntendedOrder>]
    def moves_to(territory)
      @moves[territory.abbr] || []
    end

    ##
    # @return [IntendedOrder]
    # @return [NilClass] if no order is coming from a unit at that territory
    def from(territory)
      @orders[territory.abbr]
    end

    ##
    # Determine the hold strength of a given territory
    #
    # @param [Territory] at
    # @return [Integer]
    #
    def hold_strength(at)
      unit_order_at = from(at)

      # if a unit doesn't exist here, or is moving, it has effective 0 hold strength
      return 0 if unit_order_at.nil? || unit_order_at.move?

      supporting_hold_strength(at) + 1 # 1 for the unit itself
    end

    ##
    # Determine the strength of all non-cut supports for a given territory
    #
    # @param [Territory] at
    # @return [Integer]
    #
    def supporting_hold_strength(at)
      @support_holds[at.abbr]&.reject { |o| support_cut?(at: o.assistance_territory, country: o.country) }&.size.to_i
    end

    ##
    # Find the most successful move to a given territory
    # @param [Territory] to
    # @return [IntendedOrder]
    #
    def successful_move_order_to(to)
      winning_orders = moves_to(to).max_by_all do |o|
        move_strength_to(to: o.to_territory, country: o.country)
      end
      winning_orders.size > 1 ? nil : winning_orders.first
    end

    ##
    # Determine the move strength to a given territory
    #
    # @param [Territory] to
    # @param [Country] country The country calculating move strength for
    # @return [Integer]
    #
    def move_strength_to(to:, country:)
      move_support_strength_to(to:, country:) + 1
    end

    ##
    # Determine the support strength of a move to a given territory. If the order of support to that territory is
    # cut by something moving against it, subtract that from the total.
    #
    # @param [Territory] to
    # @param [Country] country The country calculating move support for
    # @return [Integer]
    def move_support_strength_to(to:, country:)
      @support_moves[to.abbr]&.reject { |o| o.country != country || support_cut?(at: o.assistance_territory, country:) }&.size.to_i || 0
    end

    ##
    # If there are any moves to a territory, its support is effectively cut
    #
    # @param [Territory] at The country to
    # @param [Country] country The country calculating support cut for
    # @return [Boolean]
    #
    def support_cut?(at:, country:)
      @moves[at.abbr]&.any? { |o| o.country != country }
    end

    private

    def categorize(orders)
      orders.each_value do |order|
        case order.move_type
        when Order::TYPE_HOLD
          (@holds[order.from_territory.abbr] ||= []) << order
        when Order::TYPE_MOVE
          (@moves[order.to_territory.abbr] ||= []) << order
        when Order::TYPE_SUPPORT_HOLD
          (@support_holds[order.from_territory.abbr] ||= []) << order
        when Order::TYPE_SUPPORT_MOVE
          (@support_moves[order.to_territory.abbr] ||= []) << order
        when Order::TYPE_CONVOY
          (@convoys[order.to_territory.abbr] ||= []) << order
        when Order::TYPE_RETREAT
          (@retreats[order.to_territory.abbr] ||= []) << order
        when Order::TYPE_BUILD
          (@builds[order.from_territory.abbr] ||= []) << order
        when Order::TYPE_DISBAND
          (@disbands[order.from_territory.abbr] ||= []) << order
        else
          raise "Invalid order type: #{order.move_type}"
        end
      end
    end
  end
end
