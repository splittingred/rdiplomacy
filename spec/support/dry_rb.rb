# frozen_string_literal: true

# Helpers for various registered components and accessors
module DryHelpers
  def app_container
    ::Rdiplomacy::Container
  end

  def app_stub(key, obj)
    app_container.resolve(key)
    app_container.stub(key, obj)
  end

  def logger
    app_container.resolve('logger')
  end

  ##
  # @return [::Error]
  #
  def build_error(code: :internal, message: 'fail', backtrace: [])
    ::Error.new(code:, message:, backtrace:)
  end
end

RSpec.configure do |config|
  config.include ::DryHelpers

  config.before(:all) do
    app_container.enable_stubs!
  end

  config.before do
    # First unstub everything to get a clean slate
    app_container.unstub

    # Then stub some common services we always want mocked
    app_container.stub('logger', ::ActiveSupport::TaggedLogging.new(::Logger.new(File::NULL)))
  end

  config.include ::Dry::Monads::Result::Mixin
end
