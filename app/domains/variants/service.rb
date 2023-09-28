# frozen_string_literal: true

module Variants
  ##
  # Service class for interacting with variants
  #
  class Service
    # @!attribute [r] import_cmd
    #   @return [Variants::Commands::Import::Command]
    include ::Rdiplomacy::Deps[
      import_cmd: 'variants.commands.import.command'
    ]

    ##
    # @param [String] name
    # @return [Success<Variant>]
    # @return [Failure<Error>]
    #
    def import!(name:)
      request = ::Variants::Commands::Import::Request.new(name:)
      import_cmd.call(request)
    end
  end
end
