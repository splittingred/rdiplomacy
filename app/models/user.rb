# frozen_string_literal: true

class User < ApplicationRecord
  GOOGLE_OAUTH2_PROVIDER = 'google_oauth2'

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :omniauthable, omniauth_providers: [:google_oauth2]
  # :confirmable,
  # :lockable,
  # :timeoutable
  # :database_authenticatable,
  # :registerable,
  # :recoverable,
  # :rememberable,
  # :validatable

  # @!attribute players
  #   @return [ActiveRecord::Associations::CollectionProxy<Player>]
  has_many :players, dependent: nil

  def self.from_google(email:, uid:)
    find_or_create_by!(email:, uid:, username: email, provider: GOOGLE_OAUTH2_PROVIDER)
  end

  def gravatar_url
    "https://www.gravatar.com/avatar/#{::Digest::SHA256.hexdigest(email.to_s.strip.downcase)}"
  end
end
