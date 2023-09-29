# frozen_string_literal: true

##
# Base game model
#
class Game < ApplicationRecord
  # @!attribute variant
  #   @return [Variant]
  belongs_to :variant

  # @!attribute countries
  #   @return [ActiveRecord::Associations::CollectionProxy<Countries>]
  has_many :countries, dependent: :destroy
  # @!attribute moves
  #   @return [ActiveRecord::Associations::CollectionProxy<Move>]
  has_many :moves, dependent: :destroy
  # @!attribute orders
  #   @return [ActiveRecord::Associations::CollectionProxy<Orders>]
  has_many :orders, dependent: :destroy
  # @!attribute players
  #   @return [ActiveRecord::Associations::CollectionProxy<Players>]
  has_many :players, dependent: :destroy
  # @!attribute units
  #   @return [ActiveRecord::Associations::CollectionProxy<Unit>]
  has_many :units, class_name: 'Unit', dependent: :destroy
  # @!attribute turns
  #   @return [ActiveRecord::Associations::CollectionProxy<Turn>]
  has_many :turns, dependent: :destroy

  scope :for_variant, ->(variant) { where(variant:) }
  scope :with_name, ->(name) { where(name:) }

  ##
  # @return [Maps::Map]
  #
  delegate :map, to: :variant

  ##
  # Get the current turn for this game
  #
  # @return [Turn]
  # @return [NilClass]
  #
  def current_turn
    turns.current.first
  end
end
