# frozen_string_literal: true

##
# Represents an intended order (move, build, etc.) for a player in a game. This is copied from an Order during the
# adjudication step to determine if the order is valid or not.
#
class IntendedOrder < ::Entities::Base
  include Errorable
  include MoveTypeable
  include Validatable

  # @!attribute [r] order
  #  @return [Order]
  attribute(:order, Types.Instance(::Object))
  # @!attribute game
  #   @return [Game]
  attribute(:game, Types.Instance(::Object))
  # @!attribute turn
  #   @return [Turn]
  attribute(:turn, Types.Instance(::Object))
  # @!attribute [r] move_type
  #   @return [String]
  attribute(:move_type, Types::Strict::String)
  # @!attribute country
  #   @return [Country]
  attribute(:country, Types.Instance(::Object))
  # @!attribute player
  #   @return [Player]
  attribute(:player, Types.Instance(::Object))
  # @!attribute unit
  #   @return [Unit]
  attribute(:unit, Types.Instance(::Object))
  # @!attribute unit_position
  #   @return [UnitPosition]
  attribute(:unit_position, Types.Instance(::Object))
  # @!attribute from_territory
  #   @return [Territory]
  attribute(:from_territory, Types.Instance(::Object))
  # @!attribute to_territory
  #   @return [Territory]
  attribute(:to_territory, Types.Instance(::Object))
  # @!attribute assistance_territory
  #   @return [Territory]
  #   @return [NilClass] if no assisting territory in the order
  attribute(:assistance_territory, Types.Instance(::Object).optional)
  # @!attribute convoyed
  #   @return [Boolean] whether or not this order was convoyed
  attribute(:convoyed, Types::Bool.default(false))

  ##
  # @return [Boolean]
  #
  def unit_dislodged?
    unit_position.dislodged?
  end

  ##
  # @return [Boolean]
  #
  def move?
    move_type == Order::TYPE_MOVE
  end

  ##
  # @return [Boolean]
  #
  def convoy?
    move_type == Order::TYPE_CONVOY
  end

  ##
  # @return [Boolean]
  #
  def retreat?
    move_type == Order::TYPE_RETREAT
  end

  ##
  # @return [Maps::Map]
  #
  def map
    @map ||= game.map
  end
end
