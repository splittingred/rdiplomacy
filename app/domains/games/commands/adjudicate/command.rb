# frozen_string_literal: true

module Games
  module Commands
    module Adjudicate
      ##
      # Adjudicate a given turn, resolving orders into moves
      #
      class Command < ::RDiplomacy::Command
        # @!attribute [r] adjudication_service
        #   @return [Orders::AdjudicationService]
        include ::Rdiplomacy::Deps[
          adjudication_service: 'orders.adjudication_service'
        ]

        ##
        # @param [Request] request
        #
        def perform(request)
          orders = yield fetch_intended_orders(request)
          orders = yield adjudicate_orders(orders)
          moves = yield resolve_orders(orders)
          Success(moves:, orders:)
        end

        private

        ##
        # @return [Success<Hash<Symbol, IntendedOrder>>]
        # @return [Failure<Error>]
        #
        def fetch_intended_orders(request)
          Success(request.turn.intended_orders)
        end

        ##
        # @param [Hash<Symbol,IntendedOrder>] orders
        # @return [Success]
        # @return [Failure<Error>]
        #
        def adjudicate_orders(orders)
          collection = ::Entities::IntendedOrders.new(orders)
          adjudication_service.call(collection)
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
      end
    end
  end
end
