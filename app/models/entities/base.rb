# frozen_string_literal: true

module Entities
  ##
  # Base entity class that allows writers on top of dry-struct
  #
  class Base < ::Dry::Struct
    transform_keys(&:to_sym)

    attr_reader :primary_key_field

    ##
    # @return [Boolean]
    #
    def persisted?
      val = if primary_key_field.nil?
              @attributes.fetch(:id, '')
            else
              send(primary_key_field)
            end
      val.is_a?(Integer) ? !val.zero? : !val.to_s.empty?
    end

    # Resolve default types on nil
    transform_types do |type|
      if type.default?
        type.constructor do |value|
          value.nil? ? ::Dry::Types::Undefined : value
        end
      else
        # Make all types omittable
        type.omittable
      end
    end

    def self.attribute(name, type = nil, &)
      super
      define_attribute_setter(name)
    end

    def self.define_attribute_setter(name)
      define_method("#{name}=") do |value|
        self.attributes = attributes.merge(name => value)
      end
    end

    def attributes=(new_attributes)
      @attributes = attributes.merge(new_attributes)
    end
  end
end
