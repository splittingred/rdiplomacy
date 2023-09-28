# frozen_string_literal: true

##
# Represents a border between two territories
#
class Border < ApplicationRecord
  # @!attribute variant
  #   @return [Variant]
  belongs_to :variant
  # @!attribute from_territory
  #   @return [Territory]
  belongs_to :from_territory, class_name: 'Territory'
  # @!attribute to_territory
  #   @return [Territory]
  belongs_to :to_territory, class_name: 'Territory'

  scope :for_variant, ->(variant) { where(variant:) }
  scope :with_territory, lambda { |territory|
    tid = territory.is_a?(::Territory) ? territory.id : territory
    where('from_territory_id = ? OR to_territory_id = ?', tid, tid)
  }
  scope :with_territories, lambda { |territory_1, territory_2|
    tid_1 = territory_1.is_a?(::Territory) ? territory_1.id : territory_1
    tid_2 = territory_2.is_a?(::Territory) ? territory_2.id : territory_2
    where('(from_territory_id = ? AND to_territory_id = ?) OR (from_territory_id = ? AND to_territory_id = ?)', tid_1, tid_2, tid_2, tid_1)
  }
end
