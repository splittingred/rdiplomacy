# frozen_string_literal: true

class GamesController < ApplicationController
  # GET /games
  def index
    @games = games_service.search
    # no-op
  end

  # GET /games/:id
  def show
    result = games_service.find(params[:id])
    case result
    in Success(game)
      redirect_to game_turn_path(game, game.current_turn.abbr)
    else
      render_unknown_error
    end
  end

  private

  def games_service
    container['games.service']
  end
end
