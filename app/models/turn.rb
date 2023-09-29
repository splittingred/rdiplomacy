# frozen_string_literal: true

class Turn < ApplicationRecord
  # @!attribute game
  #   @retrun [Game]
  belongs_to :game
  # @!attribute moves
  #   @return [ActiveRecord::Associations::CollectionProxy<Move>]
  has_many :moves, dependent: :destroy
  # @!attribute orders
  #   @return [ActiveRecord::Associations::CollectionProxy<Order>]
  has_many :orders, dependent: :destroy
  # @!attribute unit_positions
  #   @return [ActiveRecord::Associations::CollectionProxy<UnitPosition>]
  has_many :unit_positions, dependent: :destroy

  scope :for_game, ->(game) { where(game:) }
  scope :by_year, ->(year) { where(year:) }
  scope :by_season, ->(season) { where(season:) }
  scope :current, -> { where(current: true) }

  # @!attribute [r] variant_configuration
  #   @return [Variants::Configuration]
  #   @return [NilClass]
  #   @see Game#variant_configuration
  delegate :variant_configuration, to: :game, allow_nil: true

  STATUS_AWAITING_ORDERS = 'awaiting_orders'
  STATUS_ADJUDICATING = 'adjudicating'
  STATUS_PAUSED = 'paused'
  STATUS_FINISHED = 'finished'

  ##
  # @return [Hash<Symbol,IntendedOrder>]
  #
  def intended_orders
    orders.includes(game: [], turn: [], unit_position: [:unit], country: [], player: [], from_territory: [], to_territory: [], assistance_territory: []).each_with_object({}) do |order, hash|
      hash[order.from_territory.abbr.to_sym] = order.to_intended
    end
  end

  ##
  # @return [Variants::Configuration::Season]
  #
  def current_season
    variant_configuration.seasons[season.to_s.upcase.to_sym]
  end

  ##
  # @return [String]
  #
  def name
    "#{season.to_s.upcase} #{year}"
  end

  ##
  # @return [String]
  #
  def abbr
    "#{year}-#{season.to_s.upcase}"
  end

  ##
  # @return [String]
  #
  def next_turn_abbr
    "#{next_turn_year}-#{next_turn_season.abbr.to_s.upcase}"
  end

  ##
  # @return [Variants::Configuration::Season]
  #
  def next_turn_season
    game.variant.configuration.seasons[current_season.next.to_sym]
  end

  ##
  # @return [Integer]
  #
  def next_turn_year
    last_season_of_year? ? year + 1 : year
  end

  ##
  # @return [String]
  #
  def previous_turn_abbr
    "#{previous_turn_year}-#{previous_turn_season.abbr.to_s.upcase}"
  end

  ##
  # @return [Variants::Configuration::Season]
  #
  def previous_turn_season
    variant_configuration.seasons[current_season.previous.to_sym]
  end

  ##
  # Are we in the first year?
  #
  def in_first_year?
    year == game.start_year
  end

  ##
  # Are we in the first season of the year?
  #
  # @return [Boolean]
  #
  def first_season_of_year?
    current_season.start_of_year?
  end

  ##
  # Are we in the last season of the year?
  #
  # @return [Boolean]
  #
  def last_season_of_year?
    current_season.end_of_year?
  end

  ##
  # Are we in the first turn of the game?
  #
  # @return [Boolean]
  #
  def first_turn?
    in_first_year? && first_season_of_year?
  end

  ##
  # @return [Integer]
  #
  def previous_turn_year
    if first_turn? || !first_season_of_year?
      year
    elsif first_season_of_year?
      year - 1 # return the prior year since we're in the first season of the year
    end
  end
end
