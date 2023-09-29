# frozen_string_literal: true

##
# Represents a unit in-game, such as a fleet or army.
#
# @!attribute id
#   @return [Integer]
# @!attribute game_id
#   @return [Integer]
# @!attribute country_id
#   @return [Integer]
# @!attribute unit_type
#   @return [String]
# @!attribute status
#   @return [String]
# @!attribute created_at
#   @return [DateTime]
# @!attribute updated_at
#   @return [DateTime]
class Unit < ApplicationRecord
  # @!attribute game
  #   @return [Game]
  belongs_to :game
  # @!attribute country
  #   @return [Country]
  belongs_to :country
  # @!attribute unit_positions
  #   @return [ActiveRecord::Associations::CollectionProxy<UnitPosition>]
  has_many :unit_positions, dependent: :destroy

  scope :for_game, ->(game) { where(game:) }
  scope :for_country, ->(country) { where(country:) }
  scope :active, -> { where(status: STATUS_ACTIVE) }
  scope :disbanded, -> { where(status: STATUS_DISBANDED) }
  scope :of_type, ->(unit_type) { where(unit_type:) }
  scope :army, -> { where(unit_type: TYPE_ARMY) }
  scope :fleet, -> { where(unit_type: TYPE_FLEET) }

  TYPE_ARMY = 'army'
  TYPE_FLEET = 'fleet'
  UNIT_TYPES = [TYPE_ARMY, TYPE_FLEET].freeze

  STATUS_ACTIVE = 'active'
  STATUS_DISBANDED = 'disbanded'

  ##
  # @param [Boolean] country_prefix
  # @return [String]
  #
  def to_s(country_prefix: false)
    country_prefix = country_prefix ? "#{country.to_s.upcase} " : ''
    "#{country_prefix}#{unit_type.to_s.upcase[0]}"
  end

  ##
  # @param [Territory] to
  # @param [Turn] turn
  # @return [Boolean]
  #
  def adjacent_to?(to:, turn:)
    up = unit_positions.on_turn(turn).first
    up&.adjacent_to?(to) || false
  end

  ##
  # If a unit is adjacent to a territory, and the territory can be occupied by that type of unit, it can move there.
  #
  # @param [Territory] to
  # @param [Turn] turn
  # @return [Boolean]
  #
  def can_move_to?(to:, turn:)
    adjacent_to?(to:, turn:) && territory.can_be_occupied_by?(self)
  end

  ##
  # If a unit can move to a territory, it can support a move to there.
  #
  # @param [Territory] to
  # @param [Turn] turn
  # @return [Boolean]
  #
  def can_support_move_to?(to:, turn:)
    can_move_to?(to:, turn:)
  end

  ##
  # @param [Territory] from
  # @param [Territory] to
  # @param [Turn] turn
  # @return [Boolean]
  # rubocop:disable Lint/UnusedMethodArgument
  def can_convoy?(from:, to:, turn:)
    # TODO: This will require being able to trace a path between two territories, and checking that the path is
    #   entirely occupied by fleets
    true
  end
  # rubocop:enable Lint/UnusedMethodArgument

  ##
  # @return [Boolean]
  #
  def active?
    status == STATUS_ACTIVE
  end

  ##
  # @return [Boolean]
  #
  def disbanded?
    status == STATUS_DISBANDED
  end

  ##
  # @return [Boolean]
  #
  def army?
    unit_type == TYPE_ARMY
  end

  ##
  # @return [Boolean]
  #
  def fleet?
    unit_type == TYPE_FLEET
  end
end
