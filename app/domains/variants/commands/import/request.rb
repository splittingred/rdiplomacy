# frozen_string_literal: true

module Variants
  module Commands
    module Import
      class Request < ::RDiplomacy::Request
        # @!attribute [r] abbr
        #   @return [String]
        attribute(:abbr, ::Types::Coercible::String.default('classic'))
      end
    end
  end
end
