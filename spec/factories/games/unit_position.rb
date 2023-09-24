# frozen_string_literal: true

FactoryBot.define do
  factory :unit_position, class: 'Games::UnitPosition' do
    unit
    turn
    territory

    dislodged { false }
  end
end
