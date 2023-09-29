# frozen_string_literal: true

##
# Represents a variant of a game, e.g. "default" for the default Diplomacy game, or "1900" for 1900 dip.
#
class Variant < ApplicationRecord
  # @!attribute games
  #   @return [ActiveRecord::Associations::CollectionProxy<Game>] the games that use this variant.
  has_many :games, dependent: :destroy
  # @!attribute territories
  #   @return [ActiveRecord::Associations::CollectionProxy<Territory>] the territories that belong to this variant.
  has_many :territories, dependent: :destroy

  scope :by_abbr, ->(abbr) { where(abbr:) }
  scope :with_name, ->(name) { where(name:) }

  ##
  # @return [Variants::Configuration] the configuration for this variant.
  #
  def configuration
    @configuration ||= ::Rdiplomacy::Container['variants.configuration_factory'].build(name)
  end

  ##
  # @return [Map] the map for this variant.
  #
  def map
    @map ||= ::Maps::Map.new(abbr)
  end
end
