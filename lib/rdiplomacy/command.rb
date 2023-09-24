# frozen_string_literal: true

module RDiplomacy
  class Command
    include ::Dry::Monads[:result, :do]
    extend ::Dry::Core::ClassAttributes

    ##
    # @param [::RDiplomacy::Request] request The request object for this Command
    # @return [::Dry::Monads::Result] The returned result from the derived Command class
    #
    def call(request)
      perform(request)
    end

    ##
    # @param [::RDiplomacy::Request] _request
    # @return [::Dry::Monads::Result]
    #
    def perform(_request)
      raise NotImplementedError
    end
  end
end
