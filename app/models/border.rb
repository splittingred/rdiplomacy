# frozen_string_literal: true

##
# Represents a border between two territories
#
# @!attribute id
#   @return [Integer]
# @!attribute variant_id
#   @return [Integer]
# @!attribute from_territory_abbr
#   @return [String]
# @!attribute to_territory_abbr
#   @return [String]
class Border < ApplicationRecord
  # @!attribute variant
  #   @return [Variant]
  belongs_to :variant
  # @!attribute from_territory
  #   @return [Territory]
  has_one :from_territory, class_name: 'Territory', primary_key: :from_territory_abbr, foreign_key: :abbr, dependent: nil, inverse_of: :from_borders
  # @!attribute to_territory
  #   @return [Territory]
  has_one :to_territory, class_name: 'Territory', primary_key: :to_territory_abbr, foreign_key: :abbr, dependent: nil, inverse_of: :to_borders

  scope :for_variant, ->(variant) { where(variant:) }
  scope :with_territory, lambda { |territory|
    abbr = territory.is_a?(::Territory) ? territory.abbr : territory
    where('from_territory_abbr = ? OR to_territory_abbr = ?', abbr, abbr)
  }
  scope :with_territories, lambda { |territory_1, territory_2|
    tid_1 = territory_1.is_a?(::Territory) ? territory_1.abbr : territory_1
    tid_2 = territory_2.is_a?(::Territory) ? territory_2.abbr : territory_2
    where('(from_territory_abbr = ? AND to_territory_abbr = ?) OR (from_territory_abbr = ? AND to_territory_abbr = ?)', tid_1, tid_2, tid_2, tid_1)
  }
end
