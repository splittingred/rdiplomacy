# frozen_string_literal: true

FactoryBot.define do
  factory :territory do
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

    ####################################################################################################################
    # Territory traits, build dynamically from classic map data
    ####################################################################################################################
    Maps::Map.new('classic').configuration.territories.each do |abbr, territory|
      trait abbr.to_sym do
        name { territory.name }
        abbr { territory.abbr }
        geographical_type { territory.type }
        supply_center { false }
        coast { territory.coast? }
        unit_x { territory.unit_x }
        unit_y { territory.unit_y }
        unit_dislodged_x { territory.dislodged_unit_x }
        unit_dislodged_y { territory.dislodged_unit_y }
      end
    end
  end
end
