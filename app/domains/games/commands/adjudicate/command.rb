# frozen_string_literal: true

module Games
  module Commands
    module Adjudicate
      ##
      # Adjudicate a given turn, resolving orders into moves
      #
      class Command < ::RDiplomacy::Command
        ##
        # @param [Request] request
        #
        def perform(request)
          current_turn = yield update_current_turn(request)
          ios = yield adjudicate_orders(current_turn.intended_orders)
          moves = yield resolve_orders(ios)
          new_turn = yield create_new_turn(game: request.game, current_turn:)
          yield create_new_unit_positions(turn: new_turn, orders: ios, moves:)
          current_turn = yield finish_current_turn(current_turn:)
          Success(moves:, orders: ios, current_turn:, new_turn:)
        end

        private

        def update_current_turn(request)
          current_turn = request.turn
          current_turn.status = ::Turn::STATUS_ADJUDICATING
          # current_turn.save!
          Success(current_turn)
        end

        ##
        # @param [Hash<Symbol,IntendedOrder>] orders
        # @return [Success<Entities::IntendedOrders>]
        # @return [Failure<Error>]
        #
        def adjudicate_orders(orders)
          ios = ::Entities::IntendedOrders.new(orders)
          # @type [IntendedOrder] order
          ios.each do |order|
            order.validate!(orders: ios)
          end
          Success(ios)
        end

        ##
        # @param [Entities::IntendedOrders] orders
        #
        def resolve_orders(orders)
          moves = []
          # @type [IntendedOrder] order
          orders.each do |order|
            move = Move.for_order(order.order).first_or_initialize
            move.order = order.order
            move.game = order.game
            move.country = order.country
            move.turn = order.turn
            move.player = order.player
            move.unit_position = order.unit_position
            move.move_type = order.move_type
            move.from_territory = order.from_territory
            move.to_territory = order.to_territory
            move.assistance_territory = order.assistance_territory
            move.convoyed = false # TODO: Finish convoy status
            move.successful = order.successful?
            move.dislodged = false # TODO: Finish dislodged status
            # TODO: Store adjudication errors as a human-readable string? Maybe codes too?
            # move.save!
            moves << move
          end
          Success(moves)
        end

        def create_new_turn(game:, current_turn:)
          turn = Turn.new
          turn.game = game
          turn.season = current_turn.next_turn_season.abbr
          turn.year = current_turn.next_turn_year
          turn.status = ::Turn::STATUS_AWAITING_ORDERS
          # turn.save!

          Success(turn)
        end

        def create_new_unit_positions(turn:, orders:, moves:)
          moves.each do |move|
            # TODO: Create new unit positions, handling failed moves and dislodges
          end
          Success()
        end

        def finish_current_turn(current_turn:)
          current_turn.adjucated = true
          current_turn.adjucated_at = Time.current
          current_turn.status = ::Turn::STATUS_FINISHED
          current_turn.finished_at = Time.current
          # current_turn.save!
          Success(current_turn)
        end
      end
    end
  end
end
