# frozen_string_literal: true

##
# Represents an intended order (move, build, etc.) for a player in a game.
#
class Order < ApplicationRecord
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
  #   @return [UnitPosition]
  belongs_to :unit_position
  # @!attribute assistance_territory
  #   @return [Territory]
  belongs_to :assistance_territory, class_name: 'Territory', optional: true
  # @!attribute from_territory
  #   @return [Territory]
  belongs_to :from_territory, class_name: 'Territory'
  # @!attribute to_territory
  #   @return [Territory]
  belongs_to :to_territory, class_name: 'Territory'
  # @!attribute unit
  #   @return [Unit]
  has_one :unit, through: :unit_position

  scope :for_game, ->(game) { where(game:) }
  scope :for_player, ->(player) { where(player:) }
  scope :for_country, ->(country) { where(country:) }
  scope :on_turn, ->(turn) { where(turn:) }
  scope :at, ->(territory) { where(from_territory: territory) }

  delegate :unit_type, to: :unit_position

  TYPE_HOLD = 'hold'
  TYPE_MOVE = 'move'
  TYPE_SUPPORT_HOLD = 'support-hold'
  TYPE_SUPPORT_MOVE = 'support-move'
  TYPE_CONVOY = 'convoy'
  TYPE_BUILD = 'build'
  TYPE_DISBAND = 'disband'
  TYPE_RETREAT = 'retreat'
  VALID_TYPES = [TYPE_BUILD, TYPE_CONVOY, TYPE_DISBAND, TYPE_HOLD, TYPE_MOVE, TYPE_RETREAT, TYPE_SUPPORT_HOLD, TYPE_SUPPORT_MOVE].freeze

  def to_s(country_prefix: false)
    country_prefix = country_prefix ? "#{country.to_s.upcase} " : ''
    unit = unit_position.unit.to_s
    case move_type.to_s.downcase
    when Order::TYPE_HOLD # A Sev H
      "#{country_prefix}#{unit} #{from_territory} H"
    when Order::TYPE_MOVE, Order::TYPE_RETREAT # A Kie - Mun
      "#{country_prefix}#{unit} #{from_territory} - #{to_territory}"
    when Order::TYPE_SUPPORT_HOLD # F Ion S Nap H
      supported_country_prefix = '' # TODO: Add country prefix for multi-country supports
      "#{country_prefix}#{unit} #{assistance_territory} S #{supported_country_prefix}#{from_territory} H"
    when Order::TYPE_SUPPORT_MOVE # F Aeg S Ion - Eas
      supported_country_prefix = '' # TODO: Add country prefix for multi-country supports
      "#{country_prefix}#{unit} #{assistance_territory} S #{supported_country_prefix}#{from_territory} - #{to_territory}"
    when Order::TYPE_CONVOY # F Ion C Nap - Tun
      convoyed_country_prefix = '' # TODO: Add country prefix for multi-country convoys
      "#{country_prefix}#{unit} #{assistance_territory} C #{convoyed_country_prefix}#{from_territory} - #{to_territory}"
    when Order::TYPE_DISBAND, Order::TYPE_BUILD # F Ven
      "#{country_prefix}#{unit} #{from_territory}"
    else
      ''
    end
  end

  ##
  # @return [IntendedOrder]
  #
  def to_intended
    intended_order_class.new(
      order: self,
      game:,
      turn:,
      move_type:,
      country:,
      player:,
      unit: unit_position.unit,
      unit_position:,
      from_territory:,
      to_territory:,
      assistance_territory:
    )
  end

  ##
  # @return [IntendedOrder]
  #
  def intended_order_class
    ::IntendedOrders.const_get(move_type.to_s.classify)
  rescue NameError => _e
    Container['logger'].error "Order #{self.id} is an invalid move type: #{move_type}"
    ::IntendedOrders::Hold
  end
end
