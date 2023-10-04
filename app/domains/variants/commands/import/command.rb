# frozen_string_literal: true

module Variants
  module Commands
    module Import
      class Command < ::RDiplomacy::Command
        # @!attribute [r] logger
        #   @return [Logger]
        include ::Rdiplomacy::Deps[
          logger: 'logger'
        ]

        ##
        # @param [Variants::Commands::Import::Request] request
        # @return [Success<Variant>]
        # @return [Failure<Error>]
        #
        def perform(request)
          variant_yml = yield load_variant_yml(request.name)
          variant = yield create_variant(variant_yml)
          yield setup_territories(variant:)
          yield create_borders(variant:)
          Success(variant)
        end

        private

        ##
        # @param [String] variant_name
        # @return [Success<Hash>]
        # @return [Failure<Error>]
        #
        def load_variant_yml(variant_name)
          variant_file = Rails.root.join('app', 'configuration', 'variants', "#{variant_name}.yml")
          logger.info "Loading variant configuration at #{variant_file}"
          Success(YAML.safe_load_file(variant_file))
        rescue StandardError => e
          logger.error "Failed to import variant #{variant_name}: #{e.message}"
          Failure(Error.from_exception(e))
        end

        ##
        # @param [Hash] variant_yml
        # @return [Success<Variant>]
        # @return [Failure<Error>]
        #
        def create_variant(variant_yml)
          variant = ::Variant.by_abbr(variant_yml['abbr']).first_or_initialize
          variant.name = variant_yml.fetch('name')
          variant.abbr = variant_yml.fetch('abbr')
          variant.description = variant_yml.fetch('description', '')
          variant.save!
          Success(variant)
        rescue StandardError => e
          logger.error "Failed to create variant #{variant_yml['name']}: #{e.message}"
          Failure(Error.from_exception(e))
        end

        ##
        # @param [Variant] variant
        # @return [Success<Hash<Symbol, Territory>>]
        # @return [Failure<Error>]
        #
        def setup_territories(variant:)
          # setup territory data from map
          territories = {}
          # @type [MapConfiguration::Territory] territory_config
          variant.map.configuration.territories.each do |territory_abbr, territory_config|
            territory = create_territory(variant:, abbr: territory_abbr, config: territory_config).value_or do |error|
              raise error.message
            end
            territories[territory.abbr.to_sym] = territory

            # @type [MapConfiguration::Coast] coast_config
            territory_config.coasts.each do |coast_abbr, coast_config|
              coast_full_abbr = "#{territory_abbr}-#{coast_abbr}"
              coast = create_territory(variant:, abbr: coast_full_abbr, config: coast_config, coast: true).value_or do |error|
                raise error.message
              end
              territories[coast_full_abbr.to_sym] = coast
            end
          rescue StandardError => e
            logger.error "Failed to load territory #{territory_abbr}: #{e.message}"
          end
          Success(territories)
        end

        ##
        # @param [Variant] variant
        # @param [String] abbr
        # @param [Maps::Configuration::Territory|Maps::Configuration::Coast] config
        # @param [Boolean] coast
        # @param [Territory] parent_territory
        # @return [Success<Territory>]
        # @return [Failure<Error>]
        #
        def create_territory(variant:, abbr:, config:, coast: false, parent_territory: nil)
          territory = ::Territory.for_variant(variant).with_abbr(abbr).first_or_initialize
          territory.name = config.name
          territory.geographical_type = coast ? ::Territory::GEOGRAPHICAL_TYPE_COAST : config.type
          territory.coast = coast
          territory.parent_territory_id = parent_territory.id if parent_territory
          territory.unit_x = config.unit_x
          territory.unit_y = config.unit_y
          territory.unit_dislodged_x = config.dislodged_unit_x
          territory.unit_dislodged_y = config.dislodged_unit_y
          territory.save!
          Success(territory)
        end

        ##
        # @param [Variant] variant
        # @return [Success]
        # @return [Failure<Error>]
        def create_borders(variant:)
          variant.map.configuration.territories.each do |territory_abbr, config|
            logger.debug { "Creating borders for #{territory_abbr} - #{config.borders.count}" }
            config.borders.each do |border_config|
              border = ::Border.for_variant(variant).with_territories(territory_abbr.to_s, border_config.abbr.to_s).first
              unless border
                border = ::Border.new
                border.variant = variant
                border.from_territory_abbr = territory_abbr.to_s
                border.to_territory_abbr = border_config.abbr.to_s
              end
              border.sea_passable = border_config.sea_passable?
              border.land_passable = border_config.land_passable?
              border.save!
            end
          end
          Success()
        end
      end
    end
  end
end
