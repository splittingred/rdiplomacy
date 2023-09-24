# frozen_string_literal: true

##
# Base game model
#
class Game < ApplicationRecord
  belongs_to :variant

  has_many :countries, dependent: :destroy
  has_many :moves, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :players, dependent: :destroy
  has_many :units, class_name: 'Unit', dependent: :destroy
  has_many :turns, dependent: :destroy

  scope :for_variant, ->(variant) { where(variant:) }
  scope :with_name, ->(name) { where(name:) }

  ##
  # @return [Maps::Map]
  #
  def map
    variant.map
  end

  def current_turn
    turns.current.first
  end
end
