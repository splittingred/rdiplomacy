# frozen_string_literal: true

FactoryBot.define do
  factory :border do
    variant
    from_territory_abbr { 'pie' }
    to_territory_abbr { 'mar' }
    sea_passable { true }
    land_passable { true }
  end
end
