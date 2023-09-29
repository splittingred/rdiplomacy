# frozen_string_literal: true

##
# Base game model
#
# @!attribute id
#   @return [Integer]
# @!attribute variant_id
#   @return [Integer]
# @!attribute name
#   @return [String]
# @!attribute map_abbr
#   @return [String]
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
  # @return [Variants::Configuration] the configuration for the variant of the game.
  #
  def variant_configuration
    variant.configuration
  end

  ##
  # @return [Integer]
  #
  def start_year
    variant.configuration.opts.start_year
  end

  ##
  # @return [String]
  #
  def start_season
    variant.configuration.opts.start_season
  end

  ##
  # Get the current turn for this game
  #
  # @return [Turn]
  # @return [NilClass]
  #
  def current_turn
    turns.current.first
  end

  ##
  # @return [Map] the map for this variant.
  #
  def map
    @map ||= ::Maps::Map.new(map_abbr)
  end
end
