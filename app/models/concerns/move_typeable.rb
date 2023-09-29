# frozen_string_literal: true

module MoveTypeable
  extend ActiveSupport::Concern

  included do
    Order::VALID_TYPES.each do |move_type|
      define_method("#{move_type.to_s.underscore}?") do
        self.move_type == move_type.to_s
      end
    end
  end
end
