# frozen_string_literal: true

module Games
  module Commands
    module Setup
      ##
      # Command to setup a new game. Also loads variant territories if not done already.
      # Note this idempotent so can be run again if `exclusive: true` on the request.
      #
      # TODO: Add a transaction so we don't have half-failed state.
      # TODO: Allow passing an existing game as opposed to exclusive
      #
      class Command < ::RDiplomacy::Command
        ##
        # @param [Games::Commands::Setup::Request] request
        # @return [Success<Game>]
        # @return [Failure<Error>]
        #
        def perform(request)
          # @type [Variant] variant
          variant = yield find_variant(variant_abbr: request.variant_abbr)
          # @type [Game] game
          game = yield create_game(variant:, request:)
          territories = yield setup_territories(variant:)
          countries = yield setup_countries(variant:, game:)
          turn = yield setup_first_turn(game:, variant:)
          yield setup_starting_units(game:, variant:, turn:, countries:, territories:)
          Success(game)
        end

        private

        ##
        # @param [String] variant_abbr
        # @return [Success<Variant>]
        #
        def find_variant(variant_abbr:)
          Success(::Variant.by_abbr(variant_abbr).first!)
        rescue ActiveRecord::RecordNotFound => _e
          Failure(Error.new(code: :variant_not_found, message: "Variant #{variant_abbr} not found"))
        rescue StandardError => e
          Failure(Error.from_exception(e))
        end

        ##
        # @param [Variant] variant
        # @param [Games::Commands::Setup::Request] request
        # @return [Success<Game>]
        # @return [Failure<Error>]
        #
        def create_game(variant:, request:)
          q = ::Game.for_variant(variant)
          q.with_name(request.name) if request.exclusive
          game = q.first_or_create!
          Success(game)
        end

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
              coast.geographical_type = 'coast'
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

        ##
        # @param [Variant] variant
        # @param [Game] game
        # @return [Success]
        # @return [Failure<Error>]
        def setup_countries(variant:, game:)
          countries = {}
          # setup base variant + country data
          variant.configuration.countries.each do |country_abbr, country_config|
            country = ::Country.for_game(game).by_abbr(country_abbr).first_or_initialize
            country.name = country_config.name
            country.color = country_config.color
            country.starting_supply_centers = country_config.starting_units.count # TODO: this does not work where initial unit placements are different than starting supply centers
            country.current_player_id = 1 if country.current_player_id.nil? # will be updated later
            country.save!
            countries[country.abbr.to_sym] = country
          end
          Success(countries)
        end

        ##
        # @param [Game] game
        # @param [Variant] variant
        # @return [Success<Turn>]
        # @return [Failure<Error>]
        def setup_first_turn(game:, variant:)
          options = variant.configuration.opts
          now = Time.current
          Success(
            ::Turn.for_game(game).by_year(options.start_year).by_season(options.start_season).first_or_initialize.tap do |turn|
              turn.current = true
              turn.status = Turn::STATUS_AWAITING_ORDERS
              turn.adjucated = false
              turn.started_at = now
              turn.deadline_at = now + options.turn_length.seconds
              turn.save!
            end
          )
        end

        ##
        # @param [Game] game
        # @param [Variant] variant
        # @param [Turn] turn
        # @param [Hash] countries
        # @param [Hash] territories
        #
        def setup_starting_units(game:, variant:, turn:, countries: {}, territories: {})
          units = []
          # @type [Variants::Configuration::Country] country_config
          variant.configuration.countries.each do |abbr, country_config|
            # @type [Country] country
            country = countries[abbr] || ::Country.for_game(game).by_abbr(abbr).first!

            country_config.starting_units.each do |unit_config|
              # @type [Territory] territory
              territory = territories[unit_config.territory_full_abbr.to_sym]
              unless territory
                Rails.logger.error "FAILED TO FIND TERRITORY: #{unit.territory}}"
                next
              end


              up = ::UnitPosition.on_turn(turn).for_territory(territory).first_or_initialize
              unless up.persisted? && up.unit
                unit = ::Unit.for_game(game).for_country(country).joins(:unit_positions).where(unit_positions: { territory: }).first_or_initialize.tap do |u|
                  u.unit_type = unit_config.type
                  u.save!
                  up.dislodged = false
                  up.unit = u
                  up.save!
                end
              end

              units << unit
            end
          end
          Success(units)
        end
      end
    end
  end
end
