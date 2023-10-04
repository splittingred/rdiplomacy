# frozen_string_literal: true

module Variants
  class ConfigurationFactory
    ##
    # @param [String] variant_name
    # @return [Variants::Configuration]
    #
    def build(variant_name = 'classic')
      yml = ::YAML.safe_load_file(Rails.root.join('app', 'configuration', 'variants', "#{variant_name}.yml"))

      Variants::Configuration.new.tap do |config|
        config.name = yml.fetch('name', '')
        config.description = yml.fetch('description', '')
        config.map = yml.fetch('map', 'classic')
        config.opts = build_opts(yml.fetch('options', yml.fetch('opts', {})))
        config.move_types = build_move_types(yml.fetch('move_types', {}))
        config.countries = build_countries(yml.fetch('countries', []))
        config.seasons = build_seasons(yml.fetch('seasons', {}))
      end
    end

    private

    ##
    # @param [Hash] options
    # @return [Games::VariantConfiguration::Opts]
    #
    def build_opts(options = {})
      Variants::Configuration::Opts.new(
        start_year: options.fetch('start_year', 1_901).to_i,
        start_season: options.fetch('start_season', 'SPRING').to_s.upcase,
        turn_length: options.fetch('turn_length', 86_400).to_i
      )
    end

    ##
    # @param [Array<Hash>] types
    # @return [Array<Games::VariantConfiguration::MoveType>]
    #
    def build_move_types(types)
      types.map do |type_abbr, type|
        Variants::Configuration::MoveType.new.tap do |move_type|
          # @type [Games::VariantConfiguration::MoveType] move_type
          move_type.name = type_abbr.to_s
          move_type.width = type.fetch('width', 75)
          move_type.width = type.fetch('height', 75)
        end
      end
    end

    ##
    # @param [Array] countries
    # @return [Games::VariantConfiguration::Country]
    #
    def build_countries(countries)
      result = {}
      countries.each do |yml|
        abbr = yml.fetch('abbr')
        result[abbr.to_sym] = build_country(abbr:, yml:)
      end
      result
    end

    ##
    # @param [String] abbr
    # @param [Hash] yml
    # @return [Games::VariantConfiguration::Country]
    #
    def build_country(abbr:, yml:)
      setup = yml.fetch('setup', {})

      Variants::Configuration::Country.new.tap do |country|
        # @type [Games::VariantConfiguration::Country] country
        country.name = yml.fetch('name', '')
        country.abbr = abbr
        country.possessive = yml.fetch('possessive', '')
        country.color = yml.fetch('color', '')
        country.starting_influence = setup.fetch('influence', [])
        country.starting_units = build_starting_units(setup.fetch('units', []))
      end
    end

    ##
    # @param [Array<Hash>] units
    # @return [Array<Games::VariantConfiguration::Country::StartingUnit>]
    #
    def build_starting_units(units)
      units.map do |unit|
        Variants::Configuration::Country::StartingUnit.new.tap do |starting_unit|
          # @type [Games::VariantConfiguration::Country::StartingUnit] starting_unit
          starting_unit.type = unit.fetch('type', 'army')
          starting_unit.territory = unit.fetch('territory', '')
          starting_unit.coast = unit.fetch('coast', 'false').to_s == 'true'
        end
      end
    end

    ##
    # @param [Hash] seasons
    # @return [Hash<String,Games::VariantConfiguration::Season>]
    #
    def build_seasons(seasons)
      seasons.each_with_object({}) do |(abbr, so), hash|
        hash[abbr.to_sym] = Variants::Configuration::Season.new.tap do |season|
          season.abbr = abbr
          season.name = so.fetch('name', '')
          season.next = so.fetch('next', 'sp')
          season.reconcile_units = so.fetch('reconcile_units', false) == true
          season.moves_allowed = so.fetch('moves_allowed', true) == true
          season.end_of_year = so.fetch('end_of_year', false) == true
        end
      end
    end
  end
end
