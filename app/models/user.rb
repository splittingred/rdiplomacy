# frozen_string_literal: true

class User < ApplicationRecord
  # @!attribute players
  #   @return [ActiveRecord::Associations::CollectionProxy<Player>]
  has_many :players
end
