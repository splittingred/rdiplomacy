# frozen_string_literal: true

namespace :test_data do
  desc 'Seed a standard classic game'
  task classic_1: :environment do
    Rails.logger = ::Logger.new($stdout)
    Rails.logger.level = :info

    # @type [Games::Service] games_service
    games_service = ::Rdiplomacy::Container['games.service']
    variants_service = ::Rdiplomacy::Container['variants.service']
    variant = variants_service.import!(name: 'classic').value_or do |err|
      raise "Failed to import classic variant: #{err.message}"
    end

    # create game record
    game_file = Rails.root.join('lib', 'test_cases', variant.abbr, '1.yml')
    Rails.logger.info "Loading game at #{game_file}"
    game_yml = YAML.safe_load_file(game_file)

    req = ::Games::Commands::Setup::Request.new(
      name: game_yml['name'],
      variant_abbr: variant.abbr,
      exclusive: true
    )
    # @type [Game] game
    game = games_service.setup(req).value_or do |err|
      Rails.logger.fatal "Failed to setup game: #{err.message}"
      exit 1
    end

    # load all countries + territories in memory for easier, non-repetitive loaded access
    countries = ::Country.for_game(game).index_by { |c| c.abbr.to_sym }
    territories = ::Territory.for_variant(variant).index_by { |t| t.abbr.to_sym }

    # create users + players + countries
    game_yml['players'].each do |country_abbr, username|
      country = countries[country_abbr.to_sym]

      user = ::User.where(username:).first_or_initialize.tap do |u|
        u.email = "#{username}@localhost"
        u.save!
      end

      player = ::Player.for_game(game).for_country(country).first_or_initialize.tap do |p|
        p.user = user
        p.save!
      end

      country.current_player_id = player.id
      country.save!
    end

    two_years_ago = 2.years.ago
    turn_length = variant.configuration.opts.turn_length

    # create turns + moves + orders
    game_yml['turns'].each_with_index do |turn_yml, idx|
      this_turn = ::Turn.for_game(game).by_year(turn_yml['year']).by_season(turn_yml['season']).first_or_initialize
      adjucated = turn_yml.fetch('adjucated', 'false').to_s != 'false'
      turn_additive = two_years_ago + idx + 10 # add 10 seconds to each turn to make sure they're not all at the same time

      this_turn.started_at = turn_additive
      this_turn.deadline_at = turn_additive + turn_length
      if adjucated
        this_turn.current = false
        this_turn.adjucated_at = turn_additive + turn_length
        this_turn.finished_at = turn_additive + turn_length + 5
      else
        this_turn.current = true
      end
      this_turn.save!

      turn_yml.fetch('orders', {}).each do |country_abbr, orders_yml|
        order_country = countries[country_abbr.to_sym]
        unless order_country
          Rails.logger.error "FAILED TO FIND COUNTRY FOR ORDER: #{country_abbr}"
          next
        end

        orders_yml.each do |order_yml|
          from_territory_abbr = order_yml['territory'].to_s.downcase
          from_territory = territories[from_territory_abbr.to_sym]
          to_territory_abbr = order_yml['destination'].to_s.present? ? order_yml['destination'].to_s.downcase : from_territory_abbr
          to_territory = territories[to_territory_abbr.to_sym]

          up = ::UnitPosition.on_turn(this_turn).at(from_territory).joins(:unit).where(unit: { country_id: order_country.id }).not_dislodged.first
          unless up
            Rails.logger.error "FAILED TO FIND UNIT FOR #{order_country.abbr} ON TURN #{this_turn.year}-#{this_turn.season} FOR ORDER: #{from_territory}"
            next
          end

          order = ::Order.for_game(game).on_turn(this_turn).for_country(order_country).at(from_territory).first_or_initialize
          order.player = order_country.current_player
          order.unit_position = up
          order.from_territory = from_territory
          order.to_territory = to_territory
          order.move_type = order_yml['type'].to_s.downcase
          order.convoyed = order_yml.fetch('convoyed', false).to_s == 'true'
          order.save!

          ## TODO: Make this adjudicate rather than specifically writing the moves
          move = ::Move.for_game(game).on_turn(this_turn).for_country(order_country).at(from_territory).first_or_initialize
          move.player = order_country.current_player
          move.order = order
          move.unit_position = up
          move.from_territory = from_territory
          move.to_territory = to_territory
          move.move_type = order_yml['type'].to_s.downcase
          move.convoyed = order_yml.fetch('convoyed', false).to_s == 'true'
          move.save!
        end
      end
    end
  end
end
