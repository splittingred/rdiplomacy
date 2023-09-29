# frozen_string_literal: true

##
# Represents an intended order (move, build, etc.) for a player in a game. This is copied from an Order during the
# adjudication step to determine if the order is valid or not.
#
class IntendedOrder < ::Entities::Base
  STATUS_PENDING = 'pending'
  STATUS_SUCCESS = 'success'
  STATUS_FAILURE = 'failure'

  include Errorable

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
  # @!attribute valid
  #  @return [Boolean]
  attribute(:valid, Types::Bool.default(true))
  # @!attribute status
  #  @return [String]
  attribute(:status, Types::Strict::String.default(STATUS_PENDING).enum(STATUS_PENDING, STATUS_SUCCESS, STATUS_FAILURE))

  ##
  # @return [String]
  #
  def to_s(country_prefix: false)
    country_prefix = country_prefix ? "#{country.to_s.upcase} " : ''
    case move_type.to_s.downcase
    when Order::TYPE_HOLD # A Sev H
      "#{country_prefix}#{unit} #{from_territory} H"
    when Order::TYPE_MOVE, Order::TYPE_RETREAT # A Kie - Mun
      "#{country_prefix}#{unit} #{from_territory} - #{to_territory}"
    when Order::TYPE_SUPPORT_HOLD # F Ion S Nap H
      supported_country_prefix = '' # TODO: Add country prefix for multi-country supports
      "#{country_prefix}#{unit} #{assistance_territory} S #{supported_country_prefix}#{from_territory} H"
    when Order::TYPE_SUPPORT_MOVE # F Aeg S Ion - Eas
      supported_country_prefix = '' # TODO: Add country prefix for multi-country supports
      "#{country_prefix}#{unit} #{assistance_territory} S #{supported_country_prefix}#{from_territory} - #{to_territory}"
    when Order::TYPE_CONVOY # F Ion C Nap - Tun
      convoyed_country_prefix = '' # TODO: Add country prefix for multi-country convoys
      "#{country_prefix}#{unit} #{assistance_territory} C #{convoyed_country_prefix}#{from_territory} - #{to_territory}"
    when Order::TYPE_BUILD, Order::TYPE_DISBAND # F Ven
      "#{country_prefix}#{unit} #{from_territory}"
    else
      ''
    end
  end

  ##
  # @return [Boolean]
  #
  def unit_dislodged?
    unit_position.dislodged?
  end

  ##
  # @return [Boolean]
  #
  def valid_move?
    from_territory.adjacent_to?(to_territory) && to_territory.can_be_occupied_by?(unit)
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
  def retreat?
    move_type == Order::TYPE_RETREAT
  end

  ##
  # @return [Boolean]
  #
  def support_hold?
    move_type == Order::TYPE_SUPPORT_HOLD
  end

  ##
  # @return [Boolean]
  #
  def support_move?
    move_type == Order::TYPE_SUPPORT_MOVE
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
  def hold?
    move_type == Order::TYPE_HOLD
  end

  def invalidate!(code:, message:)
    self.valid = false
    errors.add(code, message)
  end

  def validate!
    self.valid = true
  end

  ##
  # @return [Boolean]
  #
  def valid?
    valid == true
  end

  ##
  # @return [Boolean]
  #
  def invalid?
    !valid?
  end

  ##
  # @return [Boolean]
  #
  def pending?
    status == STATUS_PENDING
  end

  ##
  # @return [Boolean]
  #
  def successful?
    status == STATUS_SUCCESS
  end

  ##
  # @return [Boolean]
  #
  def failed?
    status == STATUS_FAILURE
  end

  ##
  # Succeed the move
  #
  def succeed!
    self.status = STATUS_SUCCESS
  end

  ##
  # Fail the move
  #
  # @param [Symbol] attr
  # @param [Symbol] code
  # @param [String] message
  #
  def fail!(attr, code, message = '')
    self.status = IntendedOrder::STATUS_FAILURE
    errors.add(attr, code, message:)
  end

  ##
  # @return [Maps::Map]
  #
  def map
    @map ||= game.map
  end
end
