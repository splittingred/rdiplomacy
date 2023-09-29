# frozen_string_literal: true

FactoryBot.define do
  factory :unit_position do
    turn
    transient do
      game { turn.game || build(:game) }
      country { build :country, game: }
      unit_type { :fleet }
    end
    unit { build :unit, unit_type: unit_type.to_s, game:, country: }
    territory
    dislodged { false }

    trait :dislodged do
      dislodged { true }
    end
  end
end
