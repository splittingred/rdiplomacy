# frozen_string_literal: true

module Validatable
  extend ActiveSupport::Concern

  included do
    STATUS_PENDING = 'pending'
    STATUS_SUCCESS = 'success'
    STATUS_FAILURE = 'failure'

    raise 'This concern depends on Errorable; please include it first' unless included_modules.include?(Errorable)

    # @!attribute valid
    #  @return [Boolean]
    attribute(:valid, Types::Bool.default(true))
    # @!attribute status
    #  @return [String]
    attribute(:status, Types::Strict::String.default(STATUS_PENDING).enum(STATUS_PENDING, STATUS_SUCCESS, STATUS_FAILURE))

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
      self
    end

    ##
    # Invalidate this order, marking it as "failed"
    #
    def fail!(attr, code, message)
      self.status = IntendedOrder::STATUS_FAILURE
      errors.add(attr, code, message:)
    end

    ##
    # Validate the order. This must be implemented in each child move type.
    #
    def validate!(*)
      succeed!
    end
  end
end
