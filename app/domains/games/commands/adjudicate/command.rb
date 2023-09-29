# frozen_string_literal: true

module Games
  module Commands
    module Adjudicate
      ##
      # Adjudicate a given turn, resolving orders into moves
      #
      class Command < ::RDiplomacy::Command
        # @!attribute [r] logger
        #   @return [Logger]
        include ::Rdiplomacy::Deps[
          logger: 'logger'
        ]

        ##
        # @param [Request] request
        #
        def perform(request)
          current_turn = yield update_current_turn(request)
          ios = yield adjudicate_orders(current_turn.intended_orders)
          ios = yield determine_convoyed(ios)
          moves = yield resolve_orders(ios)
          new_turn = yield create_new_turn(game: request.game, current_turn:)
          yield create_new_unit_positions(new_turn:, moves:)
          current_turn = yield finish_current_turn(current_turn:)
          Success(moves:, orders: ios, current_turn:, new_turn:)
        end

        private

        def update_current_turn(request)
          current_turn = request.turn
          current_turn.status = ::Turn::STATUS_ADJUDICATING
          current_turn.save!
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
        # @return [Success<Entities::IntendedOrders>]
        # @return [Failure<Error>]
        #
        def determine_convoyed(orders)
          # @type [IntendedOrder] order
          orders.each do |order|
            next unless order.successful? # if this order already failed, ignore

            next unless order.move? # only moves can be convoyed

            next if order.from_territory.adjacent_to?(order.to_territory) # if the unit is adjacent, it doesn't need to be convoyed

            next if order.unit_dislodged? # if the unit is dislodged, it can't be convoyed

            convoy_path = orders.convoy_path_for(from: order.from_territory, to: order.to_territory)
            if convoy_path.none?
              order.fail!(:to_territory, :failed_convoy, 'Unit failed to be convoyed')
              next
            end

            order.convoyed = true
            order.succeed!
          end
          Success(orders)
        end

        ##
        # @param [Entities::IntendedOrders] orders
        #
        def resolve_orders(orders)
          moves = []
          # @type [IntendedOrder] order
          orders.each do |order|
            move = ::Move.for_order(order.order).first_or_initialize
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
            move.convoyed = order.convoyed
            move.successful = order.successful?
            move.dislodged = false # TODO: Finish dislodged status
            # TODO: Store adjudication errors as a human-readable string? Maybe codes too?
            move.save!
            moves << move
          end
          Success(moves)
        end

        def create_new_turn(game:, current_turn:)
          turn = ::Turn.for_game(game).by_year(current_turn.next_turn_year).by_season(current_turn.next_turn_season.abbr).first_or_initialize
          turn.status = ::Turn::STATUS_AWAITING_ORDERS
          turn.save!

          Success(turn)
        end

        ##
        # @param [Turn] new_turn
        # @param [Array<Move>] moves
        # @return [Success]
        # @return [Failure<Error>]
        #
        def create_new_unit_positions(new_turn:, moves:)
          moves.each do |move|
            territory = move.from_territory
            territory = move.to_territory if move.successful? && (move.move? || move.retreat?)

            up = ::UnitPosition.on_turn(new_turn).at(territory).first_or_initialize
            up.turn = new_turn
            up.territory = territory
            up.dislodged = move.dislodged?
            up.unit = move.unit if move.unit
            up.save!

            if move.build?
              # create a new unit!
              unit = ::Unit.for_game(move.game).for_country(move.country).of_type(move.unit_type).first_or_initialize
              unit.game = move.game
              unit.country = move.country
              unit.unit_type = move.unit_type
              unit.status = ::Unit::STATUS_ACTIVE
              unit.save!

              move.unit = unit
              move.save!

              up.unit = unit
              up.save!
            elsif move.disband?
              move.unit = ::Unit::STATUS_DISBANDED
              move.unit.save!
            end
          end
          Success()
        end

        def finish_current_turn(current_turn:)
          current_turn.adjucated = true
          current_turn.adjucated_at = Time.current
          current_turn.status = ::Turn::STATUS_FINISHED
          current_turn.finished_at = Time.current
          current_turn.save!
          Success(current_turn)
        end
      end
    end
  end
end
