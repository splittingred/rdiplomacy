# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ::Dry::Monads[:result]

  def render_unknown_error
    flash[:error] = 'Unknown error'
    redirect_to root_path
  end

  def container
    ::Rdiplomacy::Container
  end
end
