# frozen_string_literal: true

FactoryBot.define do
  factory :country, class: 'Games::Country' do
    game

    current_player_id { 1 }
    name { FFaker::Name.name }
    abbr { name.to_s.downcase.underscore }
    color { 'royalblue' }
    starting_supply_centers { 3 }

    trait :italy do
      name { 'Italy' }
      abbr { 'ita' }
      color { 'forestgreen' }
      starting_supply_centers { 3 }
    end
  end
end
