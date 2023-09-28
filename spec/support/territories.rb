# frozen_string_literal: true

module TerritoryHelpers
  Maps::Map.new('classic').territories.each do |abbr, _|
    define_method("t_#{abbr}") do
      FactoryBot.build(
        :territory,
        abbr.to_sym
      )
    end
  end
end

RSpec.configure do |c|
  c.include TerritoryHelpers, territories: :classic
end
