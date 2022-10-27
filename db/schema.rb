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

ActiveRecord::Schema.define(version: 2022_03_15_104737) do

# Could not dump table "annotations" because of following ActiveRecord::StatementInvalid
#   Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'NULL' at line 1

# Could not dump table "answers" because of following ActiveRecord::StatementInvalid
#   Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'NULL' at line 1

  create_table "answers_question_options", id: false, force: :cascade do |t|
    t.integer "answer_id", null: false
    t.integer "question_option_id", null: false
    t.index ["answer_id"], name: "index_answers_question_options_on_answer_id"
  end

# Could not dump table "api_clients" because of following ActiveRecord::StatementInvalid
#   Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'NULL' at line 1

# Could not dump table "conditions" because of following ActiveRecord::StatementInvalid
#   Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'NULL' at line 1

# Could not dump table "contributors" because of following ActiveRecord::StatementInvalid
#   Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'NULL' at line 1

# Could not dump table "departments" because of following ActiveRecord::StatementInvalid
#   Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'NULL' at line 1

# Could not dump table "exported_plans" because of following ActiveRecord::StatementInvalid
#   Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'NULL' at line 1

# Could not dump table "external_api_access_tokens" because of following ActiveRecord::StatementInvalid
#   Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'NULL' at line 1

# Could not dump table "guidance_groups" because of following ActiveRecord::StatementInvalid
#   Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'NULL' at line 1

# Could not dump table "guidances" because of following ActiveRecord::StatementInvalid
#   Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'NULL' at line 1

# Could not dump table "identifier_schemes" because of following ActiveRecord::StatementInvalid
#   Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'NULL' at line 1

# Could not dump table "identifiers" because of following ActiveRecord::StatementInvalid
#   Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'NULL' at line 1

# Could not dump table "languages" because of following ActiveRecord::StatementInvalid
#   Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'NULL' at line 1

# Could not dump table "licenses" because of following ActiveRecord::StatementInvalid
#   Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'NULL' at line 1

# Could not dump table "metadata_standards" because of following ActiveRecord::StatementInvalid
#   Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'NULL' at line 1

  create_table "metadata_standards_research_outputs", force: :cascade do |t|
    t.bigint "metadata_standard_id"
    t.bigint "research_output_id"
    t.index ["metadata_standard_id"], name: "metadata_research_outputs_on_metadata"
    t.index ["research_output_id"], name: "metadata_research_outputs_on_ro"
  end

# Could not dump table "notes" because of following ActiveRecord::StatementInvalid
#   Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'NULL' at line 1

  create_table "notification_acknowledgements", id: :integer, force: :cascade do |t|
    t.integer "user_id"
    t.integer "notification_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["notification_id"], name: "index_notification_acknowledgements_on_notification_id"
    t.index ["user_id"], name: "index_notification_acknowledgements_on_user_id"
  end

# Could not dump table "notifications" because of following ActiveRecord::StatementInvalid
#   Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'NULL' at line 1

  create_table "org_token_permissions", id: :integer, force: :cascade do |t|
    t.integer "org_id"
    t.integer "token_permission_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["org_id"], name: "index_org_token_permissions_on_org_id"
    t.index ["token_permission_type_id"], name: "fk_rails_2aa265f538"
  end

# Could not dump table "orgs" because of following ActiveRecord::StatementInvalid
#   Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'NULL' at line 1

# Could not dump table "perms" because of following ActiveRecord::StatementInvalid
#   Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'NULL' at line 1

# Could not dump table "phases" because of following ActiveRecord::StatementInvalid
#   Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'NULL' at line 1

# Could not dump table "plans" because of following ActiveRecord::StatementInvalid
#   Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'NULL' at line 1

  create_table "plans_guidance_groups", id: :integer, force: :cascade do |t|
    t.integer "guidance_group_id"
    t.integer "plan_id"
    t.index ["guidance_group_id", "plan_id"], name: "index_plans_guidance_groups_on_guidance_group_id_and_plan_id"
    t.index ["guidance_group_id"], name: "fk_rails_ec1c5524d7"
    t.index ["plan_id"], name: "fk_rails_13d0671430"
  end

# Could not dump table "prefs" because of following ActiveRecord::StatementInvalid
#   Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'NULL' at line 1

# Could not dump table "question_format_labels" because of following ActiveRecord::StatementInvalid
#   Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'NULL' at line 1

# Could not dump table "question_formats" because of following ActiveRecord::StatementInvalid
#   Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'NULL' at line 1

# Could not dump table "question_options" because of following ActiveRecord::StatementInvalid
#   Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'NULL' at line 1

# Could not dump table "questions" because of following ActiveRecord::StatementInvalid
#   Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'NULL' at line 1

  create_table "questions_themes", id: false, force: :cascade do |t|
    t.integer "question_id", null: false
    t.integer "theme_id", null: false
    t.index ["question_id"], name: "index_questions_themes_on_question_id"
  end

# Could not dump table "regions" because of following ActiveRecord::StatementInvalid
#   Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'NULL' at line 1

# Could not dump table "related_identifiers" because of following ActiveRecord::StatementInvalid
#   Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'NULL' at line 1

# Could not dump table "repositories" because of following ActiveRecord::StatementInvalid
#   Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'NULL' at line 1

  create_table "repositories_research_outputs", force: :cascade do |t|
    t.bigint "research_output_id"
    t.bigint "repository_id"
    t.index ["repository_id"], name: "index_repositories_research_outputs_on_repository_id"
    t.index ["research_output_id"], name: "index_repositories_research_outputs_on_research_output_id"
  end

# Could not dump table "research_domains" because of following ActiveRecord::StatementInvalid
#   Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'NULL' at line 1

# Could not dump table "research_outputs" because of following ActiveRecord::StatementInvalid
#   Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'NULL' at line 1

  create_table "roles", id: :integer, force: :cascade do |t|
    t.integer "user_id"
    t.integer "plan_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "access", default: 0, null: false
    t.boolean "active", default: true
    t.index ["plan_id"], name: "index_roles_on_plan_id"
    t.index ["user_id"], name: "index_roles_on_user_id"
  end

# Could not dump table "sections" because of following ActiveRecord::StatementInvalid
#   Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'NULL' at line 1

# Could not dump table "sessions" because of following ActiveRecord::StatementInvalid
#   Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'NULL' at line 1

# Could not dump table "settings" because of following ActiveRecord::StatementInvalid
#   Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'NULL' at line 1

# Could not dump table "stats" because of following ActiveRecord::StatementInvalid
#   Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'NULL' at line 1

# Could not dump table "subscriptions" because of following ActiveRecord::StatementInvalid
#   Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'NULL' at line 1

# Could not dump table "templates" because of following ActiveRecord::StatementInvalid
#   Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'NULL' at line 1

# Could not dump table "themes" because of following ActiveRecord::StatementInvalid
#   Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'NULL' at line 1

  create_table "themes_in_guidance", id: false, force: :cascade do |t|
    t.integer "theme_id"
    t.integer "guidance_id"
    t.index ["guidance_id"], name: "index_themes_in_guidance_on_guidance_id"
    t.index ["theme_id"], name: "index_themes_in_guidance_on_theme_id"
  end

# Could not dump table "token_permission_types" because of following ActiveRecord::StatementInvalid
#   Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'NULL' at line 1

# Could not dump table "trackers" because of following ActiveRecord::StatementInvalid
#   Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'NULL' at line 1

# Could not dump table "users" because of following ActiveRecord::StatementInvalid
#   Mysql2::Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'NULL' at line 1

  create_table "users_perms", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "perm_id"
    t.index ["perm_id"], name: "fk_rails_457217c31c"
    t.index ["user_id"], name: "index_users_perms_on_user_id"
  end

  add_foreign_key "annotations", "orgs"
  add_foreign_key "annotations", "questions"
  add_foreign_key "answers", "plans"
  add_foreign_key "answers", "questions"
  add_foreign_key "answers", "users"
  add_foreign_key "conditions", "questions"
  add_foreign_key "guidance_groups", "orgs"
  add_foreign_key "guidances", "guidance_groups"
  add_foreign_key "notes", "answers"
  add_foreign_key "notes", "users"
  add_foreign_key "notification_acknowledgements", "notifications"
  add_foreign_key "notification_acknowledgements", "users"
  add_foreign_key "org_token_permissions", "orgs"
  add_foreign_key "org_token_permissions", "token_permission_types"
  add_foreign_key "orgs", "languages"
  add_foreign_key "orgs", "regions"
  add_foreign_key "phases", "templates"
  add_foreign_key "plans", "orgs"
  add_foreign_key "plans", "templates"
  add_foreign_key "plans_guidance_groups", "guidance_groups"
  add_foreign_key "plans_guidance_groups", "plans"
  add_foreign_key "question_options", "questions"
  add_foreign_key "questions", "question_formats"
  add_foreign_key "questions", "sections"
  add_foreign_key "research_domains", "research_domains", column: "parent_id"
  add_foreign_key "research_outputs", "licenses"
  add_foreign_key "roles", "plans"
  add_foreign_key "roles", "users"
  add_foreign_key "sections", "phases"
  add_foreign_key "templates", "orgs"
  add_foreign_key "themes_in_guidance", "guidances"
  add_foreign_key "themes_in_guidance", "themes"
  add_foreign_key "trackers", "orgs"
  add_foreign_key "users", "departments"
  add_foreign_key "users", "languages"
  add_foreign_key "users", "orgs"
end
