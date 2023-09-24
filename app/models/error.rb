# frozen_string_literal: true

##
# Generic error class for monadic failures
#
class Error
  # @!attribute [r] code
  #   @return [Symbol]
  # @!attribute [r] message
  #   @return [String]
  # @!attribute [r] backtrace
  #   @return [Array<String>]
  attr_reader :code,
              :message,
              :backtrace

  ##
  # @param [String|Symbol] code Code to identify the error (e.g. :internal_server_error)
  # @param [String] message Details that will help the user.
  # @param [Array<String>] backtrace Optionally, include a backtrace to assist with debugging.
  #
  def initialize(code:, message:, backtrace: [])
    raise ArgumentError, 'code is required' if code.to_s.empty?
    raise ArgumentError, 'message is required' if message.to_s.empty?
    raise ArgumentError, 'backtrace must be an array' unless backtrace.is_a?(Array)

    @code = code.to_sym
    @message = message
    @backtrace = backtrace
  end

  ##
  # Builds an error object from an Exception.
  #
  # @param [Exception] exception
  # @return [Bigcommerce::Dry::Monads::Error]
  #
  def self.from_exception(exception)
    new(
      code: :internal_server_error,
      message: "#{exception.class.name}: #{exception.message}",
      backtrace: exception.backtrace[0...10]
    )
  end
end
