# frozen_string_literal: true

FactoryBot.define do
  factory :territory, class: 'Games::Territory' do
    variant

    name { FFaker::Name.name }
    abbr { name.to_s.downcase.underscore }
    geographical_type { 'inland' }
    supply_center { false }
    coast { false }
    unit_x { 0 }
    unit_y { 0 }
    unit_dislodged_x { 0 }
    unit_dislodged_y { 0 }

    trait :nap do
      name { 'Naples' }
      abbr { 'nap' }
      geographical_type { 'coast' }
      supply_center { true }
      coast { true }
      unit_x { 806 }
      unit_y { 1170 }
      unit_dislodged_x { 795 }
      unit_dislodged_y { 1160 }
    end

    trait :ion do
      name { 'Ionian Sea' }
      abbr { 'ion' }
      geographical_type { 'sea' }
      supply_center { false }
      coast { false }
      unit_x { 846 }
      unit_y { 1286 }
      unit_dislodged_x { 835 }
      unit_dislodged_y { 1276 }
    end

    trait :aeg do
      name { 'Aegean Sea' }
      abbr { 'aeg' }
      geographical_type { 'sea' }
      supply_center { false }
      coast { false }
      unit_x { 1043 }
      unit_y { 1230 }
      unit_dislodged_x { 1032 }
      unit_dislodged_y { 1220 }
    end

    trait :tun do
      name { 'Tunis' }
      abbr { 'tun' }
      geographical_type { 'coast' }
      supply_center { true }
      coast { true }
      unit_x { 622 }
      unit_y { 1300 }
      unit_dislodged_x { 611 }
      unit_dislodged_y { 1290 }
    end

    trait :gre do
      name { 'Greece' }
      abbr { 'gre' }
      geographical_type { 'coast' }
      supply_center { true }
      coast { true }
      unit_x { 966 }
      unit_y { 1190 }
      unit_dislodged_x { 955 }
      unit_dislodged_y { 1180 }
    end

    trait :eas do
      name { 'Eastern Mediterranean Sea' }
      abbr { 'eas' }
      geographical_type { 'sea' }
      supply_center { false }
      coast { false }
      unit_x { 1218 }
      unit_y { 1311 }
      unit_dislodged_x { 1207 }
      unit_dislodged_y { 1301 }
    end
  end
end
