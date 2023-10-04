# frozen_string_literal: true

##
# Represents a territory (or place that a unit can go) in a game variant
#
# @!attribute id
#   @return [Integer]
# @!attribute name
#   @return [String]
# @!attribute abbr
#   @return [String]
class Territory < ApplicationRecord
  # @!attribute variant
  #  @return [Variant]
  belongs_to :variant
  # @!attribute parent_territory
  #  @return [Territory]
  #  @return [NilClass] if this territory does not have a parent territory (e.g. not a coast sub-territory)
  belongs_to :parent_territory, class_name: 'Territory', optional: true

  has_many :from_borders, class_name: 'Border', dependent: :destroy, foreign_key: :from_territory_abbr, primary_key: :abbr
  has_many :to_borders, class_name: 'Border', dependent: :destroy, foreign_key: :to_territory_id, primary_key: :abbr

  scope :for_variant, ->(variant) { where(variant:) }
  scope :with_name, ->(name) { where(name:) }
  scope :with_abbr, ->(abbr) { where(abbr:) }

  GEOGRAPHICAL_TYPE_INLAND = 'inland'
  GEOGRAPHICAL_TYPE_COAST = 'coast'
  GEOGRAPHICAL_TYPE_SEA = 'sea'
  GEOGRAPHICAL_TYPES = [GEOGRAPHICAL_TYPE_INLAND, GEOGRAPHICAL_TYPE_COAST, GEOGRAPHICAL_TYPE_SEA].freeze
  OCCUPIABLE_BY = {
    army: [GEOGRAPHICAL_TYPE_INLAND, GEOGRAPHICAL_TYPE_COAST],
    fleet: [GEOGRAPHICAL_TYPE_COAST, GEOGRAPHICAL_TYPE_SEA]
  }.freeze

  def to_s
    abbr.to_s.capitalize
  end

  ##
  # @return [Array<Border>]
  #
  def borders
    Border.for_variant(variant_id).with_territory(abbr)
  end

  ##
  # @return [Array<String>] An array of territory abbreviations that this territory borders
  #
  def border_abbrs
    borders.each_with_object([]) do |border, abbrs|
      abbrs << border.from_territory_abbr if border.from_territory_abbr != abbr
      abbrs << border.to_territory_abbr if border.to_territory_abbr != abbr
    end
  end

  ##
  # @param [Territory|String] territory
  # @return [Boolean]
  #
  def adjacent_to?(territory)
    abbr = territory.is_a?(::Territory) ? territory.abbr.to_s : territory.to_s
    border_abbrs.include?(abbr)
  end

  ##
  # @param [Unit] unit
  # @return [Boolean]
  #
  def can_be_occupied_by?(unit)
    unit_type = unit.is_a?(String) || unit.is_a?(Symbol) ? unit.to_sym : unit.unit_type.to_sym
    OCCUPIABLE_BY[unit_type].include?(geographical_type)
  end

  def inland?
    geographical_type == GEOGRAPHICAL_TYPE_INLAND
  end

  def coast?
    geographical_type == GEOGRAPHICAL_TYPE_COAST
  end

  def sea?
    geographical_type == GEOGRAPHICAL_TYPE_SEA
  end
end
