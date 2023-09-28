# frozen_string_literal: true

##
# Represents a country in a game
#
class Country < ApplicationRecord
  # @!attribute game
  #   @return [Game]
  belongs_to :game
  # Countries can have more than one player, but only one at a time (subbing allowed)
  # @!attribute players
  #   @return [ActiveRecord::Associations::CollectionProxy<Player>]
  has_many :players, dependent: :destroy
  # @!attribute current_player
  #   @return [Player]
  #   @return [NilClass]
  has_one :current_player, class_name: 'Player'

  scope :for_game, ->(game) { where(game:) }
  scope :by_abbr, ->(abbr) { where(abbr:) }

  def to_s
    abbr.upcase
  end
end
