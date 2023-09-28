# frozen_string_literal: true

FactoryBot.define do
  factory :country, class: 'Country' do
    game

    current_player_id { 1 }
    name { FFaker::Name.name }
    abbr { name.to_s.downcase.underscore }
    color { 'royalblue' }
    starting_supply_centers { 3 }

    trait :ita do
      name { 'Italy' }
      abbr { 'ita' }
      color { 'forestgreen' }
      starting_supply_centers { 3 }
    end

    trait :fra do
      name { 'France' }
      abbr { 'fra' }
      color { 'royalblue' }
      starting_supply_centers { 3 }
    end

    trait :eng do
      name { 'England' }
      abbr { 'eng' }
      color { 'darkviolet' }
      starting_supply_centers { 3 }
    end

    trait :ger do
      name { 'Germany' }
      abbr { 'ger' }
      color { '#a08a75' }
      starting_supply_centers { 3 }
    end

    trait :aus do
      name { 'Austria' }
      abbr { 'aus' }
      color { '#c48f85' }
      starting_supply_centers { 3 }
    end

    trait :rus do
      name { 'Russia' }
      abbr { 'rus' }
      color { '#757d91' }
      starting_supply_centers { 4 }
    end

    trait :tur do
      name { 'Turkey' }
      abbr { 'tur' }
      color { '#b9a61c' }
      starting_supply_centers { 3 }
    end
  end
end
