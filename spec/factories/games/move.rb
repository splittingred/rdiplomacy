# frozen_string_literal: true

FactoryBot.define do
  factory :move, class: 'Games::Move' do
    game
    country
    player
    turn
    unit_position
    assistance_territory factory: %i[territory]
    from_territory factory: %i[territory]
    to_territory factory: %i[territory]
    order
    move_type { 'MOVE' }
    convoyed { false }
    successful { true }
    dislodged { false }
  end
end
