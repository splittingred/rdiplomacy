# frozen_string_literal: true

FactoryBot.define do
  factory :unit, class: 'Games::Unit' do
    game
    country

    unit_type { 'army' }

    trait :army do
      unit_type { 'army' }
    end

    trait :fleet do
      unit_type { 'fleet' }
    end
  end
end
