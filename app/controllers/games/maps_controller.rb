# frozen_string_literal: true

require 'victor'

module Games
  class MapsController < ApplicationController
    def index
      # TODO: games list
    end

    def show
      case Views::GameMapView.call(game_id: params[:game_id])
      in Success(view)
        @view = view
        render :show
      in Failure[Integer => _code, Dry::Validation::Result => errors]
        flash[:error] = errors
        redirect_to root_path
      else
        render_unknown_error
      end
    end

    def initial
      case resolve('games.service').find(params[:game_id])
      in Success(game)
        @map = ::Games::Map.new(game.variant.name)
        @game = game
        resolve('setup.service').setup(game:, map: @map)
        render :show
      in Failure[Integer => _code, Dry::Validation::Result => errors]
        flash[:error] = errors
        redirect_to root_path
      else
        render_unknown_error
      end
    end
  end
end
