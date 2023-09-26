# frozen_string_literal: true

##
# Represents a unit position during a single turn
#
class UnitPosition < ApplicationRecord
  # @!attribute [r] turn
  #   @return [Turn]
  belongs_to :turn
  # @!attribute [r] unit
  #   @return [Unit]
  belongs_to :unit
  # @!attribute [r] territory
  #   @return [Territory]
  belongs_to :territory

  scope :on_turn, ->(turn) { where(turn:) }
  scope :for_unit, ->(unit) { where(unit:) }
  scope :for_territory, ->(territory) { where(territory:) }
  scope :at, ->(territory) { where(territory:) }
  scope :dislodged, -> { where(dislodged: true) }
  scope :not_dislodged, -> { where(dislodged: false) }

  delegate :unit_type, to: :unit

  def to_s(country_prefix: false)
    country_prefix = country_prefix ? "#{unit.country} " : ''
    "#{country_prefix}#{unit} #{territory.to_s.capitalize}"
  end

  ##
  # @param [Territory] territory
  # @return [Boolean]
  #
  def adjacent_to?(territory)
    territory.adjacent_to?(territory)
  end
end
