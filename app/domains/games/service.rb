# frozen_string_literal: true

module Games
  class Service
    include ::Dry::Monads[:result]
    # @!attribute [r] setup_cmd
    #   @return [Games::Commands::Setup::Command]
    # @!attribute [r] adjudicate_cmd
    #   @return [Games::Commands::Adjudicate::Command]
    include ::Rdiplomacy::Deps[
      setup_cmd: 'games.commands.setup.command',
      adjudicate_cmd: 'games.commands.adjudicate.command'
    ]

    def find(id)
      Success(::Game.find(id))
    end

    ##
    # Adjudicate the current turn of a game. This will resolve all orders, and store new moves.
    #
    # @param [Game] game
    # @return [Success<Game>]
    # @return [Failure<Error>]
    #
    def adjudicate_current_turn!(game:)
      request = ::Games::Commands::Adjudicate::Request.new(game:, turn: game.current_turn)
      adjudicate_cmd.call(request)
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
