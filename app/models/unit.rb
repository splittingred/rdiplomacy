# frozen_string_literal: true

##
# Represents a unit in-game, such as a fleet or army.
#
class Unit < ApplicationRecord
  belongs_to :game
  belongs_to :country
  has_many :unit_positions, dependent: :destroy

  scope :for_game, ->(game) { where(game:) }
  scope :for_country, ->(country) { where(country:) }

  TYPE_ARMY = 'army'
  TYPE_FLEET = 'fleet'
  UNIT_TYPES = [TYPE_ARMY, TYPE_FLEET].freeze

  def to_s(country_prefix: false)
    country_prefix = country_prefix ? "#{country.to_s.upcase} " : ''
    "#{country_prefix}#{unit_type.to_s.upcase[0]}"
  end

  ##
  # @param [Territory] territory
  # @return [Boolean]
  #
  def adjacent_to?(territory)
    unit_position.adjacent_to?(territory)
  end

  ##
  # If a unit is adjacent to a territory, and the territory can be occupied by that type of unit, it can move there.
  #
  # @param [Territory] territory
  # @return [Boolean]
  #
  def can_move_to?(territory)
    adjacent_to?(territory) && territory.can_be_occupied_by?(self)
  end

  ##
  # If a unit can move to a territory, it can support a hold there.
  #
  # @param [Territory] territory
  # @return [Boolean]
  #
  def can_support_hold_at?(territory)
    can_move_to?(territory)
  end

  ##
  # If a unit can move to a territory, it can support a move to there.
  #
  # @param [Territory] to_territory
  # @return [Boolean]
  #
  def can_support_move_to?(to_territory)
    can_move_to?(to_territory)
  end

  ##
  # @param [Territory] from_territory
  # @param [Territory] to_territory
  # @return [Boolean]
  #
  def can_convoy?(from_territory:, to_territory:)
    # TODO: This will require being able to trace a path between two territories, and checking that the path is
    #   entirely occupied by fleets
    true
  end

  def army?
    unit_type == TYPE_ARMY
  end

  def fleet?
    unit_type == TYPE_FLEET
  end
end
