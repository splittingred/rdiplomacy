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
          variant_yml = load_variant_yml(request.name)
          variant = create_variant(variant_yml)
          territories = yield setup_territories(variant:)
          _borders = yield setup_borders(variant:, territories:)
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
            territory = ::Territory.for_variant(variant).with_abbr(territory_abbr).first_or_initialize
            territory.name = territory_config.name
            territory.geographical_type = territory_config.type
            territory.coast = false
            territory.unit_x = territory_config.unit_x
            territory.unit_y = territory_config.unit_y
            territory.unit_dislodged_x = territory_config.dislodged_unit_x
            territory.unit_dislodged_y = territory_config.dislodged_unit_y
            territory.save!

            territories[territory.abbr.to_sym] = territory

            # @type [MapConfiguration::Coast] coast_config
            territory_config.coasts.each do |coast_abbr, coast_config|
              coast_full_abbr = "#{territory_abbr}-#{coast_abbr}"
              coast = ::Territory.for_variant(variant).with_abbr(coast_full_abbr).first_or_initialize
              coast.name = coast_config.name
              coast.geographical_type = ::Territory::GEOGRAPHICAL_TYPE_COAST
              coast.coast = true
              coast.parent_territory_id = territory.id
              coast.unit_x = coast_config.unit_x
              coast.unit_y = coast_config.unit_y
              coast.unit_dislodged_x = coast_config.dislodged_unit_x
              coast.unit_dislodged_y = coast_config.dislodged_unit_y
              coast.save!

              territories[coast_full_abbr.to_sym] = coast
            end
          rescue StandardError => e
            Rails.logger.error "Failed to load territory #{territory_abbr}: #{e.message}"
          end
          Success(territories)
        end

        def setup_borders(variant:, territories:)
          # TODO: setup borders
          Success()
        end
      end
    end
  end
end
