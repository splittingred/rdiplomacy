# frozen_string_literal: true

module RDiplomacy
  class View
    include ::Dry::Monads[:do, :result]

    def self.call(...)
      new(...).call
    end

    def initialize(*)
      super()
    end

    def call(*)
      raise NotImplementedError
    end

    private

    def container
      ::Dry::Rails::Railtie.container
    end
  end
end
