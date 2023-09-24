# frozen_string_literal: true

##
# Represents a unit position during a single turn
#
class UnitPosition < ApplicationRecord
  belongs_to :turn
  belongs_to :unit
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
end
