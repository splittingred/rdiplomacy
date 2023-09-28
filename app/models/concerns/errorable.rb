# frozen_string_literal: true

module Errorable
  extend ActiveSupport::Concern

  class_methods do
    def human_attribute_name(attr, _options = {})
      attr
    end

    def lookup_ancestors
      [self]
    end
  end

  included do
    extend ActiveModel::Naming
    include ActiveModel::Conversion

    ##
    # @return [ActiveModel::Errors]
    #
    def errors
      @errors ||= ActiveModel::Errors.new(self)
    end

    def read_attribute_for_validation(attr)
      send(attr)
    end

    ##
    # @return [Boolean]
    #
    def persisted?
      false
    end

    def model_name
      ActiveModel::Name.new(self.class, nil, self.class.name)
    end
  end
end
