# frozen_string_literal: true

::Rdiplomacy::Container.register_provider(:application) do
  prepare do
    require 'json'
    require 'logger'
  end

  start do
    register('logger', Rails.logger)
  end
end
