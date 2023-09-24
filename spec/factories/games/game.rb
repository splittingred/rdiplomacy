# frozen_string_literal: true

FactoryBot.define do
  factory :game, class: 'Games::Game' do
    variant

    name { FFaker.name }
  end
end
