# frozen_string_literal: true

class Turn < ApplicationRecord
  # @!attribute game
  #   @retrun [Game]
  belongs_to :game
  # @!attribute moves
  #   @return [ActiveRecord::Associations::CollectionProxy<Move>]
  has_many :moves, dependent: :destroy
  # @!attribute orders
  #   @return [ActiveRecord::Associations::CollectionProxy<Order>]
  has_many :orders, dependent: :destroy

  scope :for_game, ->(game) { where(game:) }
  scope :by_year, ->(year) { where(year:) }
  scope :by_season, ->(season) { where(season:) }
  scope :current, -> { where(current: true) }

  STATUS_AWAITING_ORDERS = 'awaiting_orders'
  STATUS_ADJUCATING = 'adjucating'
  STATUS_PAUSED = 'paused'

  ##
  # @return [Hash<Symbol,IntendedOrder>]
  #
  def intended_orders
    orders.includes(game: [], turn: [], unit_position: [:unit], country: [], player: [], from_territory: [], to_territory: [], assistance_territory: []).each_with_object({}) do |order, hash|
      hash[order.from_territory.abbr.to_sym] = order.to_intended
    end
  end
end
