# frozen_string_literal: true

module Games
  class TurnsController < ApplicationController
    # GET /games/:game_id/turns
    def index
      # no-op
    end

    # GET /games/:game_id/turns/:YEAR-:SEASON
    def show
      year, season = params[:id].split('-')
      case Views::GameMapView.call(game_id: params[:game_id].to_i, year: year.to_i, season: season.to_s.upcase)
      in Success(view)
        @view = view
      in Failure[Integer => _code, Dry::Validation::Result => errors]
        flash[:error] = errors
        redirect_to root_path
      else
        render_unknown_error
      end
    end
  end
end
