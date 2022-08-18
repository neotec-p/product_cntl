# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_07_10_190517) do

  create_table "asynchro_statuses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "calendars", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "year", null: false
    t.integer "month", null: false
    t.integer "day", null: false
    t.string "holiday"
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "check_sheets", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "type", null: false
    t.integer "item_id", null: false
    t.string "column1"
    t.string "standard1_top"
    t.string "standard1_bottom"
    t.string "column2"
    t.string "standard2_top"
    t.string "standard2_bottom"
    t.string "column3"
    t.string "standard3_top"
    t.string "standard3_bottom"
    t.string "column4"
    t.string "standard4_top"
    t.string "standard4_bottom"
    t.string "column5"
    t.string "standard5_top"
    t.string "standard5_bottom"
    t.string "column6"
    t.string "standard6_top"
    t.string "standard6_bottom"
    t.string "column7"
    t.string "standard7_top"
    t.string "standard7_bottom"
    t.string "column8"
    t.string "standard8_top"
    t.string "standard8_bottom"
    t.string "column9"
    t.string "standard9_top"
    t.string "standard9_bottom"
    t.string "column10"
    t.string "standard10_top"
    t.string "standard10_bottom"
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "companies", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "short_name", null: false
    t.string "zip_code", null: false
    t.string "address", null: false
    t.string "tel", null: false
    t.string "fax", null: false
    t.string "product_dept", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "customers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "code", limit: 3
    t.string "name", limit: 50
    t.string "note"
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["code"], name: "index_customers_on_code", unique: true
  end

  create_table "defective_material_stock_seqs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "defective_id", null: false
    t.integer "material_stock_id", null: false
    t.decimal "weight", precision: 10, scale: 1
    t.integer "seq", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["defective_id", "material_stock_id", "seq"], name: "index_defective_material_stock_seqs_u", unique: true
  end

  create_table "defective_process_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.integer "seq", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "defective_washer_stock_seqs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "defective_id", null: false
    t.integer "washer_stock_id", null: false
    t.integer "quantity"
    t.integer "seq", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["defective_id", "washer_stock_id", "seq"], name: "index_defective_washer_stock_seqs_u", unique: true
  end

  create_table "defectives", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "item_id", null: false
    t.string "item_customer_code", limit: 3, null: false
    t.string "item_code", limit: 4, null: false
    t.integer "model_id"
    t.date "outbreak_ymd", null: false
    t.integer "defective_process_type_id", null: false
    t.string "contents"
    t.integer "amount"
    t.decimal "weight", precision: 10, scale: 1
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "priority", default: 0
    t.integer "attempts", default: 0
    t.text "handler"
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "queue"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "item_material_seqs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "item_id", null: false
    t.integer "material_id", null: false
    t.integer "seq", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["item_id", "material_id", "seq"], name: "index_item_material_seqs_on_item_id_and_material_id_and_seq", unique: true
  end

  create_table "item_washer_seqs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "item_id", null: false
    t.integer "washer_id", null: false
    t.integer "seq", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["item_id", "washer_id", "seq"], name: "index_item_washer_seqs_on_item_id_and_washer_id_and_seq", unique: true
  end

  create_table "items", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "customer_id", null: false
    t.string "customer_code", limit: 3, null: false
    t.string "code", limit: 4, null: false
    t.string "drawing_no", null: false
    t.string "name", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.decimal "weight", precision: 10, scale: 6, null: false
    t.string "punch"
    t.string "hd_model_name1"
    t.string "hd_model_name2"
    t.string "hd_model_name3"
    t.string "ro1_model_name1"
    t.string "ro1_model_name2"
    t.string "ro1_model_name3"
    t.string "ro2_model_name1"
    t.string "ro2_model_name2"
    t.string "ro2_model_name3"
    t.string "hd_addition_model_name"
    t.string "ro1_addition_model_name"
    t.string "ro2_addition_model_name"
    t.string "vote_note"
    t.string "surface_note"
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "logical_weight_flag"
    t.index ["customer_code", "code"], name: "index_items_on_customer_code_and_code", unique: true
  end

  create_table "lots", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "production_id", null: false
    t.integer "lot_no", null: false
    t.decimal "weight", precision: 10, scale: 1
    t.integer "case"
    t.date "insert_ymd", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["lot_no"], name: "index_lots_on_lot_no", unique: true
  end

  create_table "material_orders", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "material_id", null: false
    t.integer "trader_id", null: false
    t.date "order_ymd"
    t.integer "order_weight", null: false
    t.date "delivery_ymd", null: false
    t.decimal "purchase_price", precision: 10, scale: 3
    t.date "reply_delivery_ymd"
    t.date "full_delivery_ymd"
    t.integer "print_flag", null: false
    t.integer "delivery_flag", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "material_orders_reports", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "material_order_id", null: false
    t.integer "report_id", null: false
  end

  create_table "material_production_seqs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "material_id", null: false
    t.integer "production_id", null: false
    t.integer "seq", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["material_id", "production_id", "seq"], name: "index_material_production_seqs_u", unique: true
  end

  create_table "material_stock_production_seqs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "material_stock_id", null: false
    t.integer "production_id", null: false
    t.integer "seq", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["material_stock_id", "production_id", "seq"], name: "index_material_stock_production_seqs_u", unique: true
  end

  create_table "material_stocks", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "material_id", null: false
    t.integer "material_order_id", null: false
    t.string "inspection_no"
    t.decimal "accept_weight", precision: 10, scale: 1, null: false
    t.date "accept_ymd", null: false
    t.decimal "adjust_weight", precision: 10, scale: 1
    t.integer "print_flag", null: false
    t.integer "collect_flag", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "material_stocks_reports", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "material_stock_id", null: false
    t.integer "report_id", null: false
  end

  create_table "material_unit_price_histories", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "material_id", null: false
    t.decimal "unit_price", precision: 10, scale: 3
    t.date "start_ymd", null: false
    t.date "end_ymd", null: false
    t.date "created_ymd", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["material_id", "start_ymd", "end_ymd"], name: "index_material_unit_price_histories_u", unique: true
  end

  create_table "materials", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "standard", limit: 50, null: false
    t.decimal "diameter", precision: 10, scale: 2, null: false
    t.string "surface", limit: 50
    t.string "process", limit: 50
    t.decimal "dimensions", precision: 10, scale: 2
    t.decimal "unit_price", precision: 10, scale: 3, null: false
    t.integer "unit_price_update_flag"
    t.date "start_ymd", null: false
    t.date "end_ymd", null: false
    t.date "created_ymd", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "provide_flag", null: false
  end

  create_table "memos", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "production_id", null: false
    t.integer "seq", null: false
    t.string "contents", null: false
    t.integer "user_id", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["production_id", "seq"], name: "index_memos_on_production_id_and_seq", unique: true
  end

  create_table "models", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "code", limit: 3, null: false
    t.string "name", null: false
    t.string "note"
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["code", "name"], name: "index_models_on_code_and_name", unique: true
  end

  create_table "models_process_types", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "model_id", null: false
    t.integer "process_type_id", null: false
  end

  create_table "notices", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "contents", null: false
    t.date "created_ymd", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "orders", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.date "formation_ymd", null: false
    t.string "order_no", limit: 10, null: false
    t.integer "order_amount", null: false
    t.date "delivery_ymd", null: false
    t.integer "necessary_amount"
    t.date "order_ymd", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "process_details", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "item_id", null: false
    t.integer "process_type_id", null: false
    t.string "name"
    t.string "condition"
    t.string "model"
    t.integer "hexavalent_flag"
    t.integer "tanaka_flag"
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "trader_id"
    t.index ["item_id", "process_type_id"], name: "index_process_details_on_item_id_and_process_type_id", unique: true
  end

  create_table "process_expense_histories", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "process_expense_id", null: false
    t.integer "item_id", null: false
    t.decimal "hd", precision: 10, scale: 3
    t.decimal "barrel", precision: 10, scale: 3
    t.decimal "hd_addition", precision: 10, scale: 3
    t.decimal "ro1", precision: 10, scale: 3
    t.decimal "ro1_addition", precision: 10, scale: 3
    t.decimal "ro2", precision: 10, scale: 3
    t.decimal "ro2_addition", precision: 10, scale: 3
    t.decimal "heat", precision: 10, scale: 3
    t.decimal "heat_addition", precision: 10, scale: 3
    t.decimal "surface", precision: 10, scale: 3
    t.decimal "surface_addition", precision: 10, scale: 3
    t.decimal "inspection", precision: 10, scale: 3
    t.decimal "inspection_addition", precision: 10, scale: 3
    t.decimal "ratio_hd", precision: 5, scale: 3
    t.decimal "ratio_barrel", precision: 5, scale: 3
    t.decimal "ratio_ro1", precision: 5, scale: 3
    t.decimal "ratio_ro2", precision: 5, scale: 3
    t.decimal "ratio_heat", precision: 5, scale: 3
    t.decimal "ratio_surface", precision: 5, scale: 3
    t.date "start_ymd", null: false
    t.date "end_ymd", null: false
    t.date "created_ymd", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["item_id", "start_ymd", "end_ymd"], name: "index_process_expense_histories_u", unique: true
  end

  create_table "process_expenses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "item_id", null: false
    t.decimal "hd", precision: 10, scale: 3
    t.decimal "barrel", precision: 10, scale: 3
    t.decimal "hd_addition", precision: 10, scale: 3
    t.decimal "ro1", precision: 10, scale: 3
    t.decimal "ro1_addition", precision: 10, scale: 3
    t.decimal "ro2", precision: 10, scale: 3
    t.decimal "ro2_addition", precision: 10, scale: 3
    t.decimal "heat", precision: 10, scale: 3
    t.decimal "heat_addition", precision: 10, scale: 3
    t.decimal "surface", precision: 10, scale: 3
    t.decimal "surface_addition", precision: 10, scale: 3
    t.decimal "inspection", precision: 10, scale: 3
    t.decimal "inspection_addition", precision: 10, scale: 3
    t.decimal "ratio_hd", precision: 5, scale: 3
    t.decimal "ratio_barrel", precision: 5, scale: 3
    t.decimal "ratio_ro1", precision: 5, scale: 3
    t.decimal "ratio_ro2", precision: 5, scale: 3
    t.decimal "ratio_heat", precision: 5, scale: 3
    t.decimal "ratio_surface", precision: 5, scale: 3
    t.date "start_ymd", null: false
    t.date "end_ymd", null: false
    t.date "created_ymd", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "process_orders", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "production_detail_id", null: false
    t.string "type", null: false
    t.integer "trader_id", null: false
    t.string "material"
    t.string "thickness"
    t.string "process"
    t.date "delivery_ymd", null: false
    t.string "summary1"
    t.string "summary2"
    t.string "price"
    t.date "order_ymd", null: false
    t.date "arrival_ymd"
    t.integer "print_flag", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "delivery_ymd_add"
  end

  create_table "process_orders_reports", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "process_order_id", null: false
    t.integer "report_id", null: false
  end

  create_table "process_prices", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "type", null: false
    t.integer "item_id", null: false
    t.integer "trader_id", null: false
    t.integer "material_id", null: false
    t.string "customer_code", limit: 3, null: false
    t.string "code", limit: 4, null: false
    t.string "process", null: false
    t.string "condition"
    t.decimal "price", precision: 10, scale: 3, null: false
    t.string "unit"
    t.string "set"
    t.decimal "addition_price", precision: 10, scale: 3
    t.string "addition_unit"
    t.decimal "condition_weight", precision: 10, scale: 1
    t.string "condition_following"
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "process_ratios", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "hd", null: false
    t.integer "barrel", null: false
    t.integer "ro1", null: false
    t.integer "ro2", null: false
    t.integer "heat", null: false
    t.integer "surface", null: false
    t.decimal "conf_inspection", precision: 5, scale: 3, null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "process_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.integer "protected_flag"
    t.integer "ratio_flag"
    t.integer "plan_process_flag"
    t.integer "processor_flag"
    t.integer "barrel_flag"
    t.integer "seq", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "process_category"
    t.integer "expense_sum_category"
    t.integer "search_flag"
  end

  create_table "production_details", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "production_id", null: false
    t.integer "process_detail_id", null: false
    t.integer "model_id"
    t.date "plan_start_ymd"
    t.date "plan_end_ymd"
    t.date "result_start_ymd"
    t.date "result_end_ymd"
    t.integer "result_amount_production"
    t.integer "result_amount_history"
    t.decimal "defectiveness_amount", precision: 10, scale: 1
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["model_id"], name: "index_production_details_on_model_id"
    t.index ["production_id", "process_detail_id"], name: "index_production_details_on_production_id_and_process_detail_id", unique: true
  end

  create_table "productions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "order_id", null: false
    t.integer "item_id", null: false
    t.integer "status_id", null: false
    t.integer "vote_no", null: false
    t.integer "branch1_no", null: false
    t.integer "branch2_no", null: false
    t.string "customer_code", limit: 3, null: false
    t.string "code", limit: 4, null: false
    t.integer "result_amount"
    t.date "finish_ymd"
    t.string "comment"
    t.integer "parts_fix_flag"
    t.integer "print_flag", null: false
    t.integer "summation_id"
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["vote_no", "branch1_no", "branch2_no"], name: "index_productions_on_vote_no_and_branch1_no_and_branch2_no", unique: true
  end

  create_table "productions_reports", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "production_id", null: false
    t.integer "report_id", null: false
  end

  create_table "report_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.string "dt_format"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "seq", null: false
    t.index ["code"], name: "index_report_types_on_code", unique: true
  end

  create_table "reports", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "asynchro_status_id", null: false
    t.integer "report_type_id"
    t.string "file_name"
    t.string "file_path"
    t.string "disp_name"
    t.string "content_type"
    t.integer "size"
    t.integer "user_id"
    t.string "note"
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reports_summations", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "summation_id", null: false
    t.integer "report_id", null: false
  end

  create_table "reports_washer_orders", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "washer_order_id", null: false
    t.integer "report_id", null: false
  end

  create_table "roles", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "statuses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 20
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "summation_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "summations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "summation_type_id", null: false
    t.integer "asynchro_status_id", null: false
    t.date "target_ymd", null: false
    t.integer "user_id", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "traders", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "type", null: false
    t.string "name", null: false
    t.string "zip_code"
    t.string "address"
    t.string "tel"
    t.string "fax"
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "addition_attr1"
    t.string "addition_attr2"
    t.string "addition_attr3"
    t.string "addition_attr4"
    t.string "addition_attr5"
  end

  create_table "users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "login_id", limit: 3, null: false
    t.string "hashed_password"
    t.string "salt"
    t.datetime "password_updated"
    t.string "last_name", limit: 50
    t.string "first_name", limit: 50
    t.integer "role_id", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "washer_orders", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "washer_id", null: false
    t.integer "trader_id", null: false
    t.date "order_ymd"
    t.integer "order_quantity", null: false
    t.date "delivery_ymd", null: false
    t.decimal "purchase_price", precision: 10, scale: 3
    t.date "reply_delivery_ymd"
    t.date "full_delivery_ymd"
    t.integer "print_flag", null: false
    t.integer "delivery_flag", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "washer_production_seqs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "washer_id", null: false
    t.integer "production_id", null: false
    t.integer "seq", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["washer_id", "production_id", "seq"], name: "index_washer_production_seqs_u", unique: true
  end

  create_table "washer_stock_production_seqs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "washer_stock_id", null: false
    t.integer "production_id", null: false
    t.integer "seq", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["washer_stock_id", "production_id", "seq"], name: "index_washer_stock_production_seqs_u", unique: true
  end

  create_table "washer_stocks", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "washer_id", null: false
    t.integer "washer_order_id", null: false
    t.string "inspection_no"
    t.integer "accept_quantity", null: false
    t.date "accept_ymd", null: false
    t.integer "adjust_quantity"
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "collect_flag", null: false
  end

  create_table "washer_unit_price_histories", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "washer_id", null: false
    t.decimal "unit_price", precision: 10, scale: 3
    t.date "start_ymd", null: false
    t.date "end_ymd", null: false
    t.date "created_ymd", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["washer_id", "start_ymd", "end_ymd"], name: "index_washer_unit_price_histories_u", unique: true
  end

  create_table "washers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "steel_class", null: false
    t.string "diameter", null: false
    t.string "surface"
    t.integer "unit", null: false
    t.decimal "unit_price", precision: 10, scale: 3, null: false
    t.date "start_ymd", null: false
    t.date "end_ymd", null: false
    t.date "created_ymd", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "provide_flag", null: false
  end

end
