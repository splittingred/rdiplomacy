# frozen_string_literal: true

module Games
  class Service
    include ::Dry::Monads[:result]
    # @!attribute [r] setup_cmd
    #   @return [Games::Commands::Setup::Command]
    include ::Rdiplomacy::Deps[
      setup_cmd: 'games.commands.setup.command'
    ]

    def find(id)
      Success(::Game.find(id))
    end

    ##
    # Setup a new game
    #
    # @param [Games::Commands::Setup::Request] request
    # @return [Success<Game>]
    # @return [Failure<Error>]
    #
    def setup(request)
      setup_cmd.call(request)
    end
  end
end
