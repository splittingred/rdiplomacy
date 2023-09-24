# frozen_string_literal: true

FactoryBot.define do
  factory :order, class: 'Games::Order' do
    game
    country
    player
    turn
    unit_position
    assistance_territory factory: %i[territory]
    from_territory factory: %i[territory]
    to_territory factory: %i[territory]
    move_type { 'MOVE' }
    convoyed { false }
  end
end
