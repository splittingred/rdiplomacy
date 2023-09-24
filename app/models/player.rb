# frozen_string_literal: true

class Player < ApplicationRecord
  belongs_to :user, class_name: 'User'
  belongs_to :game
  belongs_to :country

  has_many :moves
  has_many :orders

  scope :for_game, ->(game) { where(game:) }
  scope :for_country, ->(country) { where(country:) }
  scope :for_user, ->(user) { where(user:) }
end
