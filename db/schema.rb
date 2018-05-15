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

ActiveRecord::Schema.define(version: 20180412092647) do

  create_table "annotations", force: :cascade do |t|
    t.integer  "question_id"
    t.integer  "org_id"
    t.text     "text"
    t.integer  "type",        default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "annotations", ["question_id"], name: "index_annotations_on_question_id"

  create_table "answers", force: :cascade do |t|
    t.text     "text"
    t.integer  "plan_id"
    t.integer  "user_id"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version", default: 0
  end

  add_index "answers", ["plan_id"], name: "index_answers_on_plan_id"
  add_index "answers", ["question_id"], name: "index_answers_on_question_id"

  create_table "answers_question_options", id: false, force: :cascade do |t|
    t.integer "answer_id",          null: false
    t.integer "question_option_id", null: false
  end

  add_index "answers_question_options", ["answer_id"], name: "index_answers_question_options_on_answer_id"

  create_table "exported_plans", force: :cascade do |t|
    t.integer  "plan_id"
    t.integer  "user_id"
    t.string   "format"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "phase_id"
  end

  create_table "file_types", force: :cascade do |t|
    t.string   "name"
    t.string   "icon_name"
    t.integer  "icon_size"
    t.string   "icon_location"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "file_uploads", force: :cascade do |t|
    t.string   "name"
    t.string   "title"
    t.text     "description"
    t.integer  "size"
    t.boolean  "published"
    t.string   "location"
    t.integer  "file_type_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type"
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", unique: true
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"

  create_table "guidance_groups", force: :cascade do |t|
    t.string   "name"
    t.integer  "org_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.boolean  "optional_subset"
    t.boolean  "published"
  end

  add_index "guidance_groups", ["org_id"], name: "index_guidance_groups_on_org_id"

  create_table "guidances", force: :cascade do |t|
    t.text     "text"
    t.integer  "guidance_group_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "question_id"
    t.boolean  "published"
  end

  add_index "guidances", ["guidance_group_id"], name: "index_guidances_on_guidance_group_id"

  create_table "identifier_schemes", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "logo_url"
    t.text     "user_landing_url"
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
    t.boolean  "archived"
    t.integer  "answer_id"
    t.integer  "archived_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notes", ["answer_id"], name: "index_notes_on_answer_id"

  create_table "notification_acknowledgements", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "notification_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notification_acknowledgements", ["notification_id"], name: "index_notification_acknowledgements_on_notification_id"
  add_index "notification_acknowledgements", ["user_id"], name: "index_notification_acknowledgements_on_user_id"

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

  create_table "org_token_permissions", force: :cascade do |t|
    t.integer  "org_id"
    t.integer  "token_permission_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "org_token_permissions", ["org_id"], name: "index_org_token_permissions_on_org_id"

  create_table "orgs", force: :cascade do |t|
    t.string   "name"
    t.string   "abbreviation"
    t.string   "target_url"
    t.string   "wayfless_entity"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.integer  "parent_id"
    t.boolean  "is_other"
    t.string   "sort_name"
    t.text     "banner_text"
    t.string   "logo_file_name"
    t.integer  "region_id"
    t.integer  "language_id"
    t.string   "logo_uid"
    t.string   "logo_name"
    t.string   "contact_email"
    t.integer  "org_type",               default: 0,              null: false
    t.text     "links",                  default: "{\"org\":[]}"
    t.string   "contact_name"
    t.boolean  "feedback_enabled",       default: false
    t.string   "feedback_email_subject"
    t.text     "feedback_email_msg"
  end

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
    t.string   "slug"
    t.boolean  "modifiable"
  end

  add_index "phases", ["template_id"], name: "index_phases_on_template_id"

  create_table "plans", force: :cascade do |t|
    t.string   "title"
    t.integer  "template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
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

  add_index "plans", ["template_id"], name: "index_plans_on_template_id"

  create_table "plans_guidance_groups", force: :cascade do |t|
    t.integer "guidance_group_id"
    t.integer "plan_id"
  end

  add_index "plans_guidance_groups", ["guidance_group_id", "plan_id"], name: "index_plans_guidance_groups_on_guidance_group_id_and_plan_id"

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

  add_index "question_options", ["question_id"], name: "index_question_options_on_question_id"

  create_table "questions", force: :cascade do |t|
    t.text     "text"
    t.text     "default_value"
    t.integer  "number"
    t.integer  "section_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "question_format_id"
    t.boolean  "option_comment_display", default: true
    t.boolean  "modifiable"
  end

  add_index "questions", ["section_id"], name: "index_questions_on_section_id"

  create_table "questions_themes", id: false, force: :cascade do |t|
    t.integer "question_id", null: false
    t.integer "theme_id",    null: false
  end

  add_index "questions_themes", ["question_id"], name: "index_questions_themes_on_question_id"

  create_table "regions", force: :cascade do |t|
    t.string  "abbreviation"
    t.string  "description"
    t.string  "name"
    t.integer "super_region_id"
  end

  create_table "roles", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "plan_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "access",     default: 0,    null: false
    t.boolean  "active",     default: true
  end

  add_index "roles", ["plan_id"], name: "index_roles_on_plan_id"
  add_index "roles", ["user_id"], name: "index_roles_on_user_id"

  create_table "sections", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "published"
    t.integer  "phase_id"
    t.boolean  "modifiable"
  end

  add_index "sections", ["phase_id"], name: "index_sections_on_phase_id"

  create_table "settings", force: :cascade do |t|
    t.string   "var",         null: false
    t.text     "value"
    t.integer  "target_id",   null: false
    t.string   "target_type", null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "settings", ["target_type", "target_id", "var"], name: "index_settings_on_target_type_and_target_id_and_var", unique: true

  create_table "splash_logs", force: :cascade do |t|
    t.string   "destination"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
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
    t.integer  "dmptemplate_id"
    t.boolean  "migrated"
    t.boolean  "dirty",            default: false
    t.text     "links",            default: "{\"funder\":[], \"sample_plan\":[]}"
  end

  add_index "templates", ["org_id", "dmptemplate_id"], name: "template_organisation_dmptemplate_index"
  add_index "templates", ["org_id"], name: "index_templates_on_org_id"

  create_table "themes", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "locale"
  end

  create_table "themes_in_guidance", id: false, force: :cascade do |t|
    t.integer "theme_id"
    t.integer "guidance_id"
  end

  add_index "themes_in_guidance", ["guidance_id"], name: "index_themes_in_guidance_on_guidance_id"
  add_index "themes_in_guidance", ["theme_id"], name: "index_themes_in_guidance_on_theme_id"

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

  add_index "user_identifiers", ["user_id"], name: "index_user_identifiers_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "firstname"
    t.string   "surname"
    t.string   "email",                  default: "",   null: false
    t.string   "orcid_id"
    t.string   "shibboleth_id"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "encrypted_password",     default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
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
    t.boolean  "accept_terms"
    t.integer  "org_id"
    t.string   "api_token"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "language_id"
    t.string   "recovery_email"
    t.boolean  "active",                 default: true
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["org_id"], name: "index_users_on_org_id"

  create_table "users_perms", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "perm_id"
  end

  add_index "users_perms", ["user_id"], name: "index_users_perms_on_user_id"

end
