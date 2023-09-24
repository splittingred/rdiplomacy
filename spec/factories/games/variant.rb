# frozen_string_literal: true

FactoryBot.define do
  factory :variant, class: 'Games::Variant' do
    name { FFaker.name }
    abbr { name.to_s.downcase.underscore }
    description { FFaker::Lorem.sentences(2) }
    start_year { 1901 }
    start_season { 'SPRING' }
    start_order { 'MOVE' }
  end
end
