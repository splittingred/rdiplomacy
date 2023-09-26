# frozen_string_literal: true

FactoryBot.define do
  factory :intended_order do
    order
    game { order.game }
    turn { order.turn }
    move_type { Order::TYPE_MOVE }
    country { order.country }
    player { order.player }
    unit_position { order.unit_position }
    unit { order.unit_position.unit }
    from_territory factory: %i[territory]
    to_territory factory: %i[territory]
    assistance_territory factory: %i[territory]
    status { IntendedOrder::STATUS_PENDING }

    trait :move do
      move_type { Order::TYPE_MOVE }
      assistance_territory { nil }
    end

    trait :hold do
      move_type { Order::TYPE_HOLD }
      to_territory { from_territory }
      assistance_territory { nil }
    end

    trait :support_hold do
      move_type { Order::TYPE_SUPPORT_HOLD }
    end

    trait :support_move do
      move_type { Order::TYPE_SUPPORT_MOVE }
    end

    trait :convoy do
      move_type { Order::TYPE_CONVOY }
    end

    trait :retreat do
      move_type { Order::TYPE_RETREAT }
      assistance_territory { nil }
    end

    trait :build do
      move_type { Order::TYPE_BUILD }
      assistance_territory { nil }
    end

    trait :disband do
      move_type { Order::TYPE_DISBAND }
      assistance_territory { nil }
    end
  end
end
