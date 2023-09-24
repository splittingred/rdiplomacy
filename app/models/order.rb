# frozen_string_literal: true

##
# Represents an intended order (move, build, etc.) for a player in a game.
#
class Order < ApplicationRecord
  belongs_to :game
  belongs_to :player
  belongs_to :country
  belongs_to :turn
  belongs_to :unit_position
  belongs_to :assistance_territory, class_name: 'Territory', optional: true
  belongs_to :from_territory, class_name: 'Territory'
  belongs_to :to_territory, class_name: 'Territory'

  has_one :unit, through: :unit_position

  scope :for_game, ->(game) { where(game:) }
  scope :for_player, ->(player) { where(player:) }
  scope :for_country, ->(country) { where(country:) }
  scope :on_turn, ->(turn) { where(turn:) }
  scope :for_territory, ->(territory) { where(from_territory: territory) }

  delegate :unit_type, to: :unit_position

  def to_s(country_prefix: false)
    country_prefix = country_prefix ? "#{country.to_s.upcase} " : ''
    unit = unit_position.unit.to_s
    case move_type.to_s.downcase
    when 'hold' # A Sev H
      "#{country_prefix}#{unit} #{from_territory} H"
    when 'move', 'retreat' # A Kie - Mun
      "#{country_prefix}#{unit} #{from_territory} - #{to_territory}"
    when 'support-hold' # F Ion S Nap H
      supported_country_prefix = '' # TODO: Add country prefix for multi-country supports
      "#{country_prefix}#{unit} #{assistance_territory} S #{supported_country_prefix}#{from_territory} H"
    when 'support-move' # F Aeg S Ion - Eas
      supported_country_prefix = '' # TODO: Add country prefix for multi-country supports
      "#{country_prefix}#{unit} #{assistance_territory} S #{supported_country_prefix}#{from_territory} - #{to_territory}"
    when 'convoy' # F Ion C Nap - Tun
      convoyed_country_prefix = '' # TODO: Add country prefix for multi-country convoys
      "#{country_prefix}#{unit} #{assistance_territory} C #{convoyed_country_prefix}#{from_territory} - #{to_territory}"
    when 'build', 'disband' # F Ven
      "#{country_prefix}#{unit} #{from_territory}"
    else
      ''
    end
  end
end
