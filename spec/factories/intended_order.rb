# frozen_string_literal: true

FactoryBot.define do
  factory :intended_order do
    order
    unit_position { order.unit_position }
    move_type { Order::TYPE_MOVE }
    player { order.player }
    status { IntendedOrder::STATUS_PENDING }

    from_territory { unit_position.territory }
    to_territory { order.to_territory }
    assistance_territory { order.assistance_territory }

    # optional attrs
    game { turn.game || order.game }
    turn { unit_position.turn || order.turn }
    unit { unit_position.unit || order.unit_position.unit }
    country { unit.country || order.country }

    initialize_with { IntendedOrders::Move.new(attributes) }

    trait :move do
      move_type { Order::TYPE_MOVE }
      assistance_territory { nil }
      initialize_with { IntendedOrders::Move.new(attributes) }
    end

    trait :hold do
      move_type { Order::TYPE_HOLD }
      to_territory { from_territory }
      assistance_territory { nil }
      initialize_with { IntendedOrders::Hold.new(attributes) }
    end

    trait :support_hold do
      move_type { Order::TYPE_SUPPORT_HOLD }
      initialize_with { IntendedOrders::SupportHold.new(attributes) }
      to_territory { from_territory }
      assistance_territory { unit_position.territory || order.assistance_territory }
    end

    trait :support_move do
      move_type { Order::TYPE_SUPPORT_MOVE }
      initialize_with { IntendedOrders::SupportMove.new(attributes) }
      assistance_territory { unit_position.territory || order.assistance_territory }
    end

    trait :convoy do
      move_type { Order::TYPE_CONVOY }
      initialize_with { IntendedOrders::Convoy.new(attributes) }
      assistance_territory { unit_position.territory || order.assistance_territory }
    end

    trait :retreat do
      move_type { Order::TYPE_RETREAT }
      assistance_territory { nil }
      from_territory { unit_position.territory }
      initialize_with { IntendedOrders::Retreat.new(attributes) }
    end

    trait :build do
      move_type { Order::TYPE_BUILD }
      from_territory { unit_position.territory }
      to_territory { unit_position.territory }
      assistance_territory { nil }
      initialize_with { IntendedOrders::Build.new(attributes) }
    end

    trait :disband do
      move_type { Order::TYPE_DISBAND }
      from_territory { unit_position.territory }
      to_territory { unit_position.territory }
      assistance_territory { nil }
      initialize_with { IntendedOrders::Disband.new(attributes) }
    end

    trait :convoyed do
      convoyed { true }
    end
  end
end
