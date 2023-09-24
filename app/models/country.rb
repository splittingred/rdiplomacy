# frozen_string_literal: true

##
# Represents a country in a game
#
class Country < ApplicationRecord
  belongs_to :game

  # countries can have more than one player, but only one at a time (subbing allowed)
  has_many :players, dependent: :destroy

  has_one :current_player, class_name: 'Player'

  scope :for_game, ->(game) { where(game:) }
  scope :by_abbr, ->(abbr) { where(abbr:) }

  def to_s
    abbr.upcase
  end
end
