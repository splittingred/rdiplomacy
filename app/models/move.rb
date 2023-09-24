# frozen_string_literal: true

##
# Represents an executed move in a game.
#
class Move < ApplicationRecord
  belongs_to :game
  belongs_to :player
  belongs_to :country
  belongs_to :turn
  belongs_to :unit_position
  belongs_to :assistance_territory, class_name: 'Territory', optional: true
  belongs_to :from_territory, class_name: 'Territory'
  belongs_to :to_territory, class_name: 'Territory'
  belongs_to :order

  has_one :unit, through: :unit_position

  scope :for_game, ->(game) { where(game:) }
  scope :for_player, ->(player) { where(player:) }
  scope :for_country, ->(country) { where(country:) }
  scope :on_turn, ->(turn) { where(turn:) }
  scope :for_territory, ->(territory) { where(from_territory: territory) }
end
