# frozen_string_literal: true

##
# Represents a territory (or place that a unit can go) in a game variant
#
class Territory < ApplicationRecord
  belongs_to :variant
  has_many :borders
  belongs_to :parent_territory, class_name: 'Territory', optional: true

  scope :for_variant, ->(variant) { where(variant:) }
  scope :with_name, ->(name) { where(name:) }
  scope :with_abbr, ->(abbr) { where(abbr: abbr) }

  def to_s
    abbr.to_s.capitalize
  end
end
