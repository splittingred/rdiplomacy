# frozen_string_literal: true

FactoryBot.define do
  factory :turn do
    game

    year { 1901 }
    season { 'SPRING' }
    current { true }

    trait :S1901 do
      year { 1901 }
      season { 'SPRING' }
    end

    trait :F1901 do
      year { 1901 }
      season { 'FALL' }
    end

    trait :W1901 do
      year { 1901 }
      season { 'WINTER' }
    end

    trait :S1902 do
      year { 1902 }
      season { 'SPRING' }
    end

    trait :F1902 do
      year { 1902 }
      season { 'FALL' }
    end

    trait :W1902 do
      year { 1902 }
      season { 'WINTER' }
    end
  end
end
