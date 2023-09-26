# frozen_string_literal: true

FactoryBot.define do
  factory :variant do
    name { FFaker.name }
    abbr { name.to_s.downcase.underscore }
    description { FFaker::Lorem.sentences(2) }
  end
end
