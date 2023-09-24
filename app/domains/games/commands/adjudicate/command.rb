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
        include ::Rdiplomacy::Deps[
          order_validator: 'orders.intended_order_validator'
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
            order_validator.call(order: order)
          end
          Success()
        end

        ##
        # @param [Hash<Symbol,IntendedOrder>] orders
        # @return [Success]
        # @return [Failure<Error>]
        #
        def adjudicate_orders(orders)
          # TODO: resolve orders
          Success()
        end
      end
    end
  end
end
