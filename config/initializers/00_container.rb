# frozen_string_literal: true

require 'dry/monads/all'
require 'dry/rails'
require 'dry/struct'

Dry::Rails.container do
  # cherry-pick features
  config.features = %i[application_contract safe_params controller_helpers]
  config.component_dirs.add('app/domains')
end

module Types
  include ::Dry::Types()

  # rubocop:disable Lint/BooleanSymbol
  FALSE_VALUES = [
    false, 0,
    '0', :'0',
    'f', :f,
    'F', :F,
    'false', :false,
    'FALSE', :FALSE,
    'off', :off,
    'OFF', :OFF,
    ''
  ].to_set.freeze
  # rubocop:enable Lint/BooleanSymbol

  Coercible::Bool = Types::Bool.constructor do |value|
    !FALSE_VALUES.include?(value)
  end
end
