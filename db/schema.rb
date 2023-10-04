# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_10_02_123624) do
  create_table "borders", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "variant_id", null: false
    t.string "from_territory_abbr", null: false
    t.string "to_territory_abbr", null: false
    t.boolean "sea_passable", default: false, null: false
    t.boolean "land_passable", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["from_territory_abbr"], name: "index_borders_on_from_territory_abbr"
    t.index ["to_territory_abbr"], name: "index_borders_on_to_territory_abbr"
    t.index ["variant_id"], name: "index_borders_on_variant_id"
  end

  create_table "countries", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.bigint "current_player_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.string "abbr"
    t.string "color"
    t.integer "starting_supply_centers", default: 1, null: false
    t.index ["current_player_id"], name: "index_countries_on_current_player_id"
    t.index ["game_id"], name: "index_countries_on_game_id"
  end

  create_table "games", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.bigint "variant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["variant_id"], name: "index_games_on_variant_id"
  end

  create_table "moves", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "game_id"
    t.bigint "country_id"
    t.bigint "player_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "turn_id"
    t.string "move_type"
    t.boolean "convoyed"
    t.boolean "successful"
    t.boolean "dislodged"
    t.bigint "order_id", null: false
    t.bigint "unit_position_id", null: false
    t.bigint "from_territory_id", null: false
    t.bigint "to_territory_id", null: false
    t.bigint "assistance_territory_id"
    t.index ["country_id"], name: "index_moves_on_country_id"
    t.index ["from_territory_id"], name: "index_moves_on_from_territory_id"
    t.index ["game_id"], name: "index_moves_on_game_id"
    t.index ["order_id"], name: "index_moves_on_order_id"
    t.index ["player_id"], name: "index_moves_on_player_id"
    t.index ["to_territory_id"], name: "index_moves_on_to_territory_id"
    t.index ["unit_position_id"], name: "index_moves_on_unit_position_id"
  end

  create_table "orders", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "game_id"
    t.bigint "country_id"
    t.bigint "player_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "turn_id"
    t.boolean "convoyed"
    t.bigint "unit_position_id", null: false
    t.bigint "from_territory_id", null: false
    t.bigint "to_territory_id", null: false
    t.string "move_type"
    t.bigint "assistance_territory_id"
    t.index ["country_id"], name: "index_orders_on_country_id"
    t.index ["from_territory_id"], name: "index_orders_on_from_territory_id"
    t.index ["game_id"], name: "index_orders_on_game_id"
    t.index ["player_id"], name: "index_orders_on_player_id"
    t.index ["to_territory_id"], name: "index_orders_on_to_territory_id"
    t.index ["unit_position_id"], name: "index_orders_on_unit_position_id"
  end

  create_table "players", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.bigint "country_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_players_on_country_id"
    t.index ["game_id"], name: "index_players_on_game_id"
    t.index ["user_id"], name: "index_players_on_user_id"
  end

  create_table "territories", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "variant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "abbr"
    t.string "geographical_type", default: "land"
    t.boolean "supply_center", default: false
    t.bigint "parent_territory_id"
    t.boolean "coast"
    t.float "unit_x"
    t.float "unit_y"
    t.float "unit_dislodged_x"
    t.float "unit_dislodged_y"
    t.index ["variant_id"], name: "index_territories_on_variant_id"
  end

  create_table "turns", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "year", null: false
    t.string "season", null: false
    t.boolean "current", default: false
    t.string "status"
    t.boolean "adjucated", default: false
    t.datetime "adjucated_at"
    t.datetime "deadline_at"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.index ["game_id"], name: "index_turns_on_game_id"
  end

  create_table "unit_positions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "unit_id", null: false
    t.integer "turn_id", default: 1, null: false
    t.integer "territory_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "dislodged", default: false
    t.index ["unit_id"], name: "index_unit_positions_on_unit_id"
  end

  create_table "units", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "game_id"
    t.bigint "country_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "unit_type", null: false
    t.index ["country_id"], name: "index_units_on_country_id"
    t.index ["game_id"], name: "index_units_on_game_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "username"
    t.string "email"
    t.datetime "joined_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "variants", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "abbr", null: false
    t.string "description"
  end

end
