# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20190620120126) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "annotations", force: :cascade do |t|
    t.integer  "question_id"
    t.integer  "org_id"
    t.text     "text"
    t.integer  "type",                      default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "versionable_id", limit: 36
  end

  add_index "annotations", ["org_id"], name: "annotations_org_id_idx", using: :btree
  add_index "annotations", ["question_id"], name: "annotations_question_id_idx", using: :btree
  add_index "annotations", ["versionable_id"], name: "index_annotations_on_versionable_id", using: :btree

  create_table "answers", force: :cascade do |t|
    t.text     "text"
    t.integer  "plan_id"
    t.integer  "user_id"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",       default: 0
    t.boolean  "is_common",          default: false
    t.integer  "research_output_id"
  end

  add_index "answers", ["plan_id"], name: "answers_plan_id_idx", using: :btree
  add_index "answers", ["question_id"], name: "answers_question_id_idx", using: :btree
  add_index "answers", ["research_output_id"], name: "index_answers_on_research_output_id", using: :btree
  add_index "answers", ["user_id"], name: "answers_user_id_idx", using: :btree

  create_table "answers_question_options", id: false, force: :cascade do |t|
    t.integer "answer_id",          null: false
    t.integer "question_option_id", null: false
  end

  add_index "answers_question_options", ["answer_id"], name: "answers_question_options_answer_id_idx", using: :btree
  add_index "answers_question_options", ["question_option_id"], name: "answers_question_options_question_option_id_idx", using: :btree

  create_table "exported_plans", force: :cascade do |t|
    t.integer  "plan_id"
    t.integer  "user_id"
    t.string   "format"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "phase_id"
  end

  create_table "guidance_groups", force: :cascade do |t|
    t.string   "name"
    t.integer  "org_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.boolean  "optional_subset", default: false, null: false
    t.boolean  "published",       default: false, null: false
  end

  add_index "guidance_groups", ["org_id"], name: "guidance_groups_org_id_idx", using: :btree

  create_table "guidances", force: :cascade do |t|
    t.text     "text"
    t.integer  "guidance_group_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.boolean  "published"
  end

  add_index "guidances", ["guidance_group_id"], name: "guidances_guidance_group_id_idx", using: :btree

  create_table "homepage_messages", force: :cascade do |t|
    t.string   "level"
    t.text     "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "identifier_schemes", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo_url"
    t.string   "user_landing_url"
  end

  create_table "languages", force: :cascade do |t|
    t.string  "abbreviation"
    t.string  "description"
    t.string  "name"
    t.boolean "default_language"
  end

  create_table "notes", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "text"
    t.boolean  "archived",    default: false, null: false
    t.integer  "answer_id"
    t.integer  "archived_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notes", ["answer_id"], name: "notes_answer_id_idx", using: :btree
  add_index "notes", ["user_id"], name: "notes_user_id_idx", using: :btree

  create_table "notification_acknowledgements", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "notification_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notification_acknowledgements", ["notification_id"], name: "notification_acknowledgements_notification_id_idx", using: :btree
  add_index "notification_acknowledgements", ["user_id"], name: "notification_acknowledgements_user_id_idx", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.integer  "notification_type"
    t.string   "title"
    t.integer  "level"
    t.text     "body"
    t.boolean  "dismissable"
    t.date     "starts_at"
    t.date     "expires_at"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "org_identifiers", force: :cascade do |t|
    t.string   "identifier"
    t.string   "attrs"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "org_id"
    t.integer  "identifier_scheme_id"
  end

  add_index "org_identifiers", ["identifier_scheme_id"], name: "org_identifiers_identifier_scheme_id_idx", using: :btree
  add_index "org_identifiers", ["org_id"], name: "org_identifiers_org_id_idx", using: :btree

  create_table "org_token_permissions", force: :cascade do |t|
    t.integer  "org_id"
    t.integer  "token_permission_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "org_token_permissions", ["org_id"], name: "org_token_permissions_org_id_idx", using: :btree
  add_index "org_token_permissions", ["token_permission_type_id"], name: "org_token_permissions_token_permission_type_id_idx", using: :btree

  create_table "orgs", force: :cascade do |t|
    t.string   "name"
    t.string   "abbreviation"
    t.string   "target_url"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "is_other",               default: false, null: false
    t.string   "sort_name"
    t.text     "banner_text"
    t.integer  "region_id"
    t.integer  "language_id"
    t.string   "logo_uid"
    t.string   "logo_name"
    t.string   "contact_email"
    t.integer  "org_type",               default: 0,     null: false
    t.text     "links"
    t.string   "contact_name"
    t.boolean  "feedback_enabled",       default: false
    t.string   "feedback_email_subject"
    t.text     "feedback_email_msg"
  end

  add_index "orgs", ["language_id"], name: "orgs_language_id_idx", using: :btree
  add_index "orgs", ["region_id"], name: "orgs_region_id_idx", using: :btree

  create_table "perms", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "phases", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "number"
    t.integer  "template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "modifiable"
    t.string   "versionable_id", limit: 36
  end

  add_index "phases", ["template_id"], name: "phases_template_id_idx", using: :btree
  add_index "phases", ["versionable_id"], name: "index_phases_on_versionable_id", using: :btree

  create_table "plans", force: :cascade do |t|
    t.string   "title"
    t.integer  "template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "grant_number"
    t.string   "identifier"
    t.text     "description"
    t.string   "principal_investigator"
    t.string   "principal_investigator_identifier"
    t.string   "data_contact"
    t.string   "funder_name"
    t.integer  "visibility",                        default: 3,     null: false
    t.string   "data_contact_email"
    t.string   "data_contact_phone"
    t.string   "principal_investigator_email"
    t.string   "principal_investigator_phone"
    t.boolean  "feedback_requested",                default: false
    t.boolean  "complete",                          default: false
  end

  add_index "plans", ["template_id"], name: "plans_template_id_idx", using: :btree

  create_table "plans_guidance_groups", force: :cascade do |t|
    t.integer "guidance_group_id"
    t.integer "plan_id"
  end

  add_index "plans_guidance_groups", ["guidance_group_id"], name: "plans_guidance_groups_guidance_group_id_idx", using: :btree
  add_index "plans_guidance_groups", ["plan_id"], name: "plans_guidance_groups_plan_id_idx", using: :btree

  create_table "prefs", force: :cascade do |t|
    t.text    "settings"
    t.integer "user_id"
  end

  create_table "question_formats", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "option_based", default: false
    t.integer  "formattype",   default: 0
  end

  create_table "question_options", force: :cascade do |t|
    t.integer  "question_id"
    t.string   "text"
    t.integer  "number"
    t.boolean  "is_default"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "question_options", ["question_id"], name: "question_options_question_id_idx", using: :btree

  create_table "questions", force: :cascade do |t|
    t.text     "text"
    t.text     "default_value"
    t.integer  "number"
    t.integer  "section_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "question_format_id"
    t.boolean  "option_comment_display",            default: true
    t.boolean  "modifiable"
    t.string   "versionable_id",         limit: 36
  end

  add_index "questions", ["question_format_id"], name: "questions_question_format_id_idx", using: :btree
  add_index "questions", ["section_id"], name: "questions_section_id_idx", using: :btree
  add_index "questions", ["versionable_id"], name: "index_questions_on_versionable_id", using: :btree

  create_table "questions_themes", id: false, force: :cascade do |t|
    t.integer "question_id", null: false
    t.integer "theme_id",    null: false
  end

  add_index "questions_themes", ["question_id"], name: "questions_themes_question_id_idx", using: :btree
  add_index "questions_themes", ["theme_id"], name: "questions_themes_theme_id_idx", using: :btree

  create_table "regions", force: :cascade do |t|
    t.string  "abbreviation"
    t.string  "description"
    t.string  "name"
    t.integer "super_region_id"
  end

  create_table "research_outputs", force: :cascade do |t|
    t.string   "name"
    t.integer  "order"
    t.text     "description"
    t.boolean  "is_default",  default: false
    t.integer  "plan_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "research_outputs", ["plan_id"], name: "index_research_outputs_on_plan_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "plan_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "access",     default: 0,     null: false
    t.boolean  "active",     default: false
  end

  add_index "roles", ["plan_id"], name: "roles_plan_id_idx", using: :btree
  add_index "roles", ["user_id"], name: "roles_user_id_idx", using: :btree

  create_table "sections", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "phase_id"
    t.boolean  "modifiable"
    t.string   "versionable_id", limit: 36
  end

  add_index "sections", ["phase_id"], name: "sections_phase_id_idx", using: :btree
  add_index "sections", ["versionable_id"], name: "index_sections_on_versionable_id", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 64, null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "settings", force: :cascade do |t|
    t.string   "var",         null: false
    t.text     "value"
    t.integer  "target_id",   null: false
    t.string   "target_type", null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "settings", ["target_type", "target_id", "var"], name: "settings_target_type_target_id_var_key", unique: true, using: :btree

  create_table "static_page_contents", force: :cascade do |t|
    t.string   "title"
    t.text     "content"
    t.integer  "static_page_id", null: false
    t.integer  "language_id",    null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "static_page_contents", ["language_id"], name: "index_static_page_contents_on_language_id", using: :btree
  add_index "static_page_contents", ["static_page_id"], name: "index_static_page_contents_on_static_page_id", using: :btree

  create_table "static_pages", force: :cascade do |t|
    t.string   "name",                         null: false
    t.string   "url",                          null: false
    t.boolean  "in_navigation", default: true
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "stats", force: :cascade do |t|
    t.integer  "count",      limit: 8, default: 0
    t.date     "date",                             null: false
    t.string   "type",                             null: false
    t.integer  "org_id"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.text     "details"
  end

  create_table "templates", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.boolean  "published"
    t.integer  "org_id"
    t.string   "locale"
    t.boolean  "is_default"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "version"
    t.integer  "visibility"
    t.integer  "customization_of"
    t.integer  "family_id"
    t.boolean  "archived"
    t.text     "links"
  end

  add_index "templates", ["customization_of", "version", "org_id"], name: "templates_customization_of_version_org_id_key", unique: true, using: :btree
  add_index "templates", ["family_id", "version"], name: "templates_family_id_version_key", unique: true, using: :btree
  add_index "templates", ["org_id"], name: "templates_org_id_idx", using: :btree

  create_table "themes", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "locale"
    t.string   "slug"
  end

  create_table "themes_in_guidance", id: false, force: :cascade do |t|
    t.integer "theme_id"
    t.integer "guidance_id"
  end

  add_index "themes_in_guidance", ["guidance_id"], name: "themes_in_guidance_guidance_id_idx", using: :btree
  add_index "themes_in_guidance", ["theme_id"], name: "themes_in_guidance_theme_id_idx", using: :btree

  create_table "token_permission_types", force: :cascade do |t|
    t.string   "token_type"
    t.text     "text_description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_identifiers", force: :cascade do |t|
    t.string   "identifier"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "identifier_scheme_id"
  end

  add_index "user_identifiers", ["identifier_scheme_id"], name: "user_identifiers_identifier_scheme_id_idx", using: :btree
  add_index "user_identifiers", ["user_id"], name: "user_identifiers_user_id_idx", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "firstname"
    t.string   "surname"
    t.string   "email",                  limit: 80, default: "",   null: false
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.string   "encrypted_password",                default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                     default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.string   "other_organisation"
    t.boolean  "dmponline3"
    t.boolean  "accept_terms"
    t.integer  "org_id"
    t.string   "api_token"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "language_id"
    t.string   "recovery_email"
    t.boolean  "active",                            default: true
  end

  add_index "users", ["email"], name: "users_email_key", unique: true, using: :btree
  add_index "users", ["language_id"], name: "users_language_id_idx", using: :btree
  add_index "users", ["org_id"], name: "users_org_id_idx", using: :btree

  create_table "users_perms", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "perm_id"
  end

  add_index "users_perms", ["perm_id"], name: "users_perms_perm_id_idx", using: :btree
  add_index "users_perms", ["user_id"], name: "users_perms_user_id_idx", using: :btree

  add_foreign_key "annotations", "orgs"
  add_foreign_key "annotations", "questions"
  add_foreign_key "answers", "plans"
  add_foreign_key "answers", "questions"
  add_foreign_key "answers", "research_outputs"
  add_foreign_key "answers", "users"
  add_foreign_key "answers_question_options", "answers"
  add_foreign_key "answers_question_options", "question_options"
  add_foreign_key "guidance_groups", "orgs"
  add_foreign_key "guidances", "guidance_groups"
  add_foreign_key "notes", "answers"
  add_foreign_key "notes", "users"
  add_foreign_key "notification_acknowledgements", "notifications"
  add_foreign_key "notification_acknowledgements", "users"
  add_foreign_key "org_identifiers", "identifier_schemes"
  add_foreign_key "org_identifiers", "orgs"
  add_foreign_key "org_token_permissions", "orgs"
  add_foreign_key "org_token_permissions", "token_permission_types"
  add_foreign_key "orgs", "languages"
  add_foreign_key "orgs", "regions"
  add_foreign_key "phases", "templates"
  add_foreign_key "plans", "templates"
  add_foreign_key "plans_guidance_groups", "guidance_groups"
  add_foreign_key "plans_guidance_groups", "plans"
  add_foreign_key "question_options", "questions"
  add_foreign_key "questions", "question_formats"
  add_foreign_key "questions", "sections"
  add_foreign_key "questions_themes", "questions"
  add_foreign_key "questions_themes", "themes"
  add_foreign_key "research_outputs", "plans"
  add_foreign_key "roles", "plans"
  add_foreign_key "roles", "users"
  add_foreign_key "sections", "phases"
  add_foreign_key "static_page_contents", "languages"
  add_foreign_key "static_page_contents", "static_pages"
  add_foreign_key "templates", "orgs"
  add_foreign_key "themes_in_guidance", "guidances"
  add_foreign_key "themes_in_guidance", "themes"
  add_foreign_key "user_identifiers", "identifier_schemes"
  add_foreign_key "user_identifiers", "users"
  add_foreign_key "users", "languages"
  add_foreign_key "users", "orgs"
  add_foreign_key "users_perms", "perms"
  add_foreign_key "users_perms", "users"
end
