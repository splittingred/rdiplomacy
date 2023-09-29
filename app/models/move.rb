# frozen_string_literal: true

##
# Represents an executed move in a game.
#
class Move < ApplicationRecord
  # @!attribute game
  #   @return [Game]
  belongs_to :game
  # @!attribute player
  #   @return [Player]
  belongs_to :player
  # @!attribute country
  #   @return [Country]
  belongs_to :country
  # @!attribute turn
  #   @return [Turn]
  belongs_to :turn
  # @!attribute unit_position
  #   @return [UnitPosition
  belongs_to :unit_position
  # @!attribute assistance_territory
  #   @return [Territory]
  #   @return [NilClass] if not a supporting move
  belongs_to :assistance_territory, class_name: 'Territory', optional: true
  # @!attribute from_territory
  #   @return [Territory]
  belongs_to :from_territory, class_name: 'Territory'
  # @!attribute to_territory
  #   @return [Territory]
  belongs_to :to_territory, class_name: 'Territory'
  # @!attribute order
  #   @return [Order]
  belongs_to :order
  # @!attribute unit
  #   @return [Unit]
  has_one :unit, through: :unit_position

  scope :for_game, ->(game) { where(game:) }
  scope :for_player, ->(player) { where(player:) }
  scope :for_country, ->(country) { where(country:) }
  scope :for_order, ->(order) { where(order:) }
  scope :on_turn, ->(turn) { where(turn:) }
  scope :at, ->(territory) { where(from_territory: territory) }
end
