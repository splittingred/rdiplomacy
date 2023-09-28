# frozen_string_literal: true

FactoryBot.define do
  factory :unit_position do
    unit
    turn
    territory
    dislodged { false }

    trait :dislodged do
      dislodged { true }
    end
  end
end
