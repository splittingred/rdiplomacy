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
  def can_move_to?(territory)
    # TODO: Store borders so can look this up here
    true
  end

  ##
  # @param [Territory] territory
  # @return [Boolean]
  #
  def can_support_hold?(territory)
    # TODO: Store borders so can look this up here
    true
  end

  ##
  # @param [Territory] from_territory
  # @param [Territory] to_territory
  # @return [Boolean]
  #
  def can_support_move?(from_territory:, to_territory:)
    # TODO: Store borders so can look this up here
    true
  end

  ##
  # @param [Territory] from_territory
  # @param [Territory] to_territory
  # @return [Boolean]
  #
  def can_convoy?(from_territory:, to_territory:)
    # TODO: Store borders so can look this up here
    true
  end

  def army?
    unit_type == TYPE_ARMY
  end

  def fleet?
    unit_type == TYPE_FLEET
  end
end
