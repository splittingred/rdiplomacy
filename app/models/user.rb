# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable
         # :confirmable,
         # :lockable,
         # :timeoutable

  # @!attribute players
  #   @return [ActiveRecord::Associations::CollectionProxy<Player>]
  has_many :players, dependent: nil
end
