# frozen_string_literal: true

FactoryBot.define do
  factory :order do
    game
    country
    player
    turn
    unit_position
    assistance_territory factory: %i[territory]
    from_territory factory: %i[territory]
    to_territory factory: %i[territory]
    move_type { Order::TYPE_MOVE }
    convoyed { false }
  end
end
