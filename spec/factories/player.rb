# frozen_string_literal: true

FactoryBot.define do
  factory :player do
    game
    country
    user
  end
end
