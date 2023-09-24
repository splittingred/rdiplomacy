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

  GEOGRAPHICAL_TYPE_INLAND = 'inland'
  GEOGRAPHICAL_TYPE_COAST = 'coast'
  GEOGRAPHICAL_TYPE_SEA = 'sea'
  GEOGRAPHICAL_TYPES = [GEOGRAPHICAL_TYPE_INLAND, GEOGRAPHICAL_TYPE_COAST, GEOGRAPHICAL_TYPE_SEA].freeze

  def to_s
    abbr.to_s.capitalize
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
