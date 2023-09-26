# frozen_string_literal: true

module Games
  module Commands
    module Adjudicate
      ##
      # Adjudicate a given turn, resolving orders into moves
      #
      class Command < ::RDiplomacy::Command
        # @!attribute [r] order_validator
        #   @return [Orders::IntendedOrderValidator]
        # @!attribute [r] adjudication_service
        #   @return [Orders::AdjudicationService]
        include ::Rdiplomacy::Deps[
          order_validator: 'orders.intended_order_validator',
          adjudication_service: 'orders.adjudication_service'
        ]

        ##
        # @param [Request] request
        #
        def perform(request)
          orders = yield fetch_intended_orders(request)
          yield validate_orders(orders)
          yield adjudicate_orders(orders)
          Success()
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
        def validate_orders(orders)
          orders.each do |order|
            order_validator.call(order:)
          end
          Success()
        end

        ##
        # @param [Hash<Symbol,IntendedOrder>] orders
        # @return [Success]
        # @return [Failure<Error>]
        #
        def adjudicate_orders(orders)
          valid_orders = orders.filter { |_, order| order.valid? }
          collection = Entities::IntendedOrders.new(valid_orders)
          adjudication_service.call(collection)
        end
      end
    end
  end
end
