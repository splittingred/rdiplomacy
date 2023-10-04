# frozen_string_literal: true

module VariantClassicHelpers
  VARIANT_ABBR = 'classic'

  Variants::ConfigurationFactory.new.build(VARIANT_ABBR).countries.each do |abbr, _|
    define_method("country_#{abbr}") do
      instance_variable_set(:"@country_#{abbr}", FactoryBot.build(:country, abbr.to_sym, game:))
    end
  end

  territories_cache = {}
  Maps::Map.new(VARIANT_ABBR).territories.each do |territory_abbr, t|
    define_method("t_#{territory_abbr}") do
      territory = instance_variable_get(:"@t_#{territory_abbr}")
      return territory if territory

      territory = FactoryBot.build(:territory, territory_abbr.to_sym, variant: classic_variant)

      territories_cache[territory_abbr.to_sym] = territory
      from_borders = []
      t.borders.each do |b|
        from_borders << FactoryBot.build(
          :border,
          variant: classic_variant,
          from_territory_abbr: territory_abbr,
          to_territory_abbr: b.abbr,
          sea_passable: b.sea_passable?,
          land_passable: b.land_passable?
        )
      end
      instance_variable_set(:"@t_#{territory_abbr}_borders", from_borders)
      territory.from_borders = from_borders
      instance_variable_set(:"@t_#{territory_abbr}", territory)
      allow(territory).to(receive(:borders).and_return(from_borders))
      territory
    end
  end

  def classic_variant
    @classic_variant ||= FactoryBot.build(:variant, :classic)
  end

  def game(attrs = {})
    @game ||= FactoryBot.build(:game, **attrs.merge(name: 'Game 1', variant: classic_variant))
  end
end

RSpec.configure do |c|
  c.include VariantClassicHelpers, variant: :classic
end
