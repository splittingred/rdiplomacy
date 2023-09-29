# frozen_string_literal: true

module Entities
  class IntendedOrders
    include ::Enumerable

    SELF_STRENGTH = 1

    # @!attribute [r] orders
    #   @return [Hash{Symbol, IntendedOrder}]
    attr_reader :orders

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
      @orders.values.each(&)
    end

    ##
    # @param [String|Territory] territory
    # @return [Array<IntendedOrder>]
    def moves_to(territory)
      @moves[(territory.is_a?(Territory) ? territory.abbr : territory)] || []
    end

    ##
    # @param [String|Territory] territory
    # @return [IntendedOrder]
    # @return [NilClass] if no order is coming from a unit at that territory
    def from(territory)
      @orders[(territory.is_a?(Territory) ? territory.abbr : territory)]
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

      supporting_hold_strength(at) + SELF_STRENGTH
    end

    ##
    # Determine the strength of all non-cut supports for a given territory
    #
    # @param [Territory] at
    # @return [Integer]
    #
    def supporting_hold_strength(at)
      @support_holds[at.abbr]&.reject do |o|
        support_cut?(at: o.assistance_territory, country: o.country) || # if support is cut
          !o.from_territory.can_be_occupied_by?(o.unit) # or the supporting unit cannot actually move to supported territory
      end&.size.to_i
    end

    ##
    # Find the most successful move to a given territory
    # @param [Territory] to
    # @return [IntendedOrder]
    #
    def winning_move_order_to(to)
      winning_orders = moves_to(to).max_by_all { |o| move_strength_to(from: o.from_territory, to: o.to_territory) }
      winning_orders.size == 1 ? winning_orders.first : nil
    end

    ##
    # Determine the move strength to a given territory
    #
    # @param [Territory] from
    # @param [Territory] to
    # @return [Integer]
    #
    def move_strength_to(from:, to:)
      move_support_strength_to(from:, to:) + SELF_STRENGTH
    end

    ##
    # Determine the support strength of a move to a given territory. If the order of support to that territory is
    # cut by something moving against it, subtract that from the total.
    #
    # @param [Territory|String] from
    # @param [Territory|String] to
    # @return [Integer]
    def move_support_strength_to(from:, to:)
      to = to.abbr if to.is_a?(Territory)
      from = from.abbr if from.is_a?(Territory)

      @support_moves[to]&.reject do |supporting_order|
        supporting_order.from_territory.abbr != from || # the support is for the wrong unit
          support_cut?(at: supporting_order.assistance_territory, country: supporting_order.country) || # or the support is cut
          !supporting_order.to_territory.can_be_occupied_by?(supporting_order.unit) # or the supporting unit cannot actually move to supported territory
      end&.size.to_i || 0
    end

    ##
    # Determine if a territory is occupied by a unit. Essentially, if an order comes from a territory, we can
    # assume that territory is occupied. (This works because we process NMRs as holds, effectively, so every territory
    # with a unit in it gets an order.)
    #
    # @param [Territory] territory
    # @return [Boolean]
    #
    def territory_occupied?(territory)
      territory = territory.abbr if territory.is_a?(Territory)
      @orders.key?(territory)
    end

    ##
    # If there are any moves to a territory, its support is effectively cut
    #
    # @param [Territory|String] at The country that is supporting
    # @param [Country|String] country The country calculating support cut for
    # @return [Boolean]
    #
    def support_cut?(at:, country:)
      at = at.abbr if at.is_a?(Territory)
      country = country.abbr if country.is_a?(Country)
      @moves[at]&.any? { |o| o.country.abbr != country } || false
    end

    ##
    # Return all convoys for a given territory
    #
    # @param [Territory|String] territory
    # @return [Array<IntendedOrder>]
    #
    def convoys_for(territory)
      territory_abbr = territory.is_a?(Territory) ? territory.abbr : territory
      @convoys[territory_abbr] || []
    end

    ##
    # Determine a valid convoy path for orders. Note that this _must_ be evaluated after _all_ orders are evaluated
    # to ensure that validity checks and dislodges of fleets are calculated prior to finding the convoy path.
    #
    # @return [Array<IntendedOrder>]
    #
    def convoy_path_for(from:, to:)
      convoys = convoys_for(from)

      # remove all convoys:
      # * not convoying to the same target
      # * that have failed
      # * have dislodged units
      convoys.reject! do |o|
        o.to_territory.abbr != to.abbr || o.failed? || o.unit_dislodged?
      end

      # TODO: get true path from this list of valid convoys. Ensure the path is a connected line.

      convoys
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
