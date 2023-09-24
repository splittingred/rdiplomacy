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

  def to_s(country_prefix: false)
    country_prefix = country_prefix ? "#{country.to_s.upcase} " : ''
    "#{country_prefix}#{unit_type.to_s.upcase[0]}"
  end
end
