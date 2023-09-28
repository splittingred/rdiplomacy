# frozen_string_literal: true

class Player < ApplicationRecord
  # @!attribute user
  #  @return [User]
  belongs_to :user
  # @!attribute game
  #  @return [Game]
  belongs_to :game
  # @!attribute country
  #  @return [User]
  belongs_to :country
  # @!attribute moves
  #   @return [ActiveRecord::Associations::CollectionProxy<Move>]
  has_many :moves
  # @!attribute orders
  #   @return [ActiveRecord::Associations::CollectionProxy<Order>]
  has_many :orders

  scope :for_game, ->(game) { where(game:) }
  scope :for_country, ->(country) { where(country:) }
  scope :for_user, ->(user) { where(user:) }
end
