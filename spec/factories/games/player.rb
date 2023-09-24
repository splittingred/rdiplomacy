# frozen_string_literal: true

FactoryBot.define do
  factory :player, class: 'Games::Player' do
    game
    country
    user
  end
end
