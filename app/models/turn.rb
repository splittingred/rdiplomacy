# frozen_string_literal: true

class Turn < ApplicationRecord
  belongs_to :game

  has_many :moves
  has_many :orders

  scope :for_game, ->(game) { where(game:) }
  scope :by_year, ->(year) { where(year:) }
  scope :by_season, ->(season) { where(season:) }
  scope :current, -> { where(current: true) }

  STATUS_AWAITING_ORDERS = 'awaiting_orders'
  STATUS_ADJUCATING = 'adjucating'
  STATUS_PAUSED = 'paused'
end
