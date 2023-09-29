# frozen_string_literal: true

::Rdiplomacy::Container.register_provider(:application) do
  prepare do
    require 'json'
    require 'logger'
    require 'rgl/adjacency'
    require 'rgl/path'
  end

  start do
    register('logger', Rails.logger)
  end
end
