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

ActiveRecord::Schema[7.1].define(version: 2024_05_29_083343) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "boroughs", force: :cascade do |t|
    t.text "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gazetteer_entries", force: :cascade do |t|
    t.text "borough"
    t.integer "usrn"
    t.text "name"
    t.text "match_name"
    t.text "address1"
    t.text "address2"
    t.text "maintenace"
    t.text "ownership"
    t.float "lat"
    t.float "lng"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mews", force: :cascade do |t|
    t.text "name"
    t.text "alt_name"
    t.float "lat"
    t.float "lng"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "actual_mews"
    t.boolean "visited"
    t.datetime "visited_at", precision: nil
    t.text "notes"
    t.text "order_id"
    t.text "canonical_id"
  end

  create_table "mews_boroughs", force: :cascade do |t|
    t.integer "mews_id"
    t.integer "borough_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mews_images", force: :cascade do |t|
    t.integer "mews_id"
    t.datetime "taken_at", precision: nil
    t.string "upload_at_timestamp"
    t.float "lat"
    t.float "lng"
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mews_sources", force: :cascade do |t|
    t.integer "mews_id"
    t.integer "os_open_name_id"
    t.integer "osm_feature_id"
    t.integer "price_paid_data_point_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "gazetteer_entry_id"
  end

  create_table "os_open_names", force: :cascade do |t|
    t.text "os_id"
    t.text "names_uri"
    t.text "name1"
    t.text "name1_lang"
    t.text "name2"
    t.text "name2_lang"
    t.text "os_type"
    t.text "local_type"
    t.integer "geometry_x"
    t.integer "geometry_y"
    t.integer "most_detail_view_res"
    t.integer "least_detail_view_res"
    t.integer "mbr_xmin"
    t.integer "mbr_ymin"
    t.integer "mbr_xmax"
    t.integer "mbr_ymax"
    t.text "postcode_district"
    t.text "postcode_district_uri"
    t.text "populated_place"
    t.text "populated_place_uri"
    t.text "populated_place_type"
    t.text "district_borough"
    t.text "district_borough_uri"
    t.text "district_borough_type"
    t.text "county_unitary"
    t.text "county_unitary_uri"
    t.text "county_unitary_type"
    t.text "region"
    t.text "region_uri"
    t.text "country"
    t.text "country_uri"
    t.text "related_spatial_object"
    t.text "same_as_dbpedia"
    t.text "same_as_geonames"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "latitude"
    t.float "longitude"
  end

  create_table "osm_features", force: :cascade do |t|
    t.text "feature_type"
    t.float "osm_id"
    t.text "address"
    t.float "latitude"
    t.float "longitude"
    t.text "borough"
    t.text "tags"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "price_paid_data_points", force: :cascade do |t|
    t.text "postcode"
    t.text "address"
    t.text "borough"
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "settings", force: :cascade do |t|
    t.text "key"
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
