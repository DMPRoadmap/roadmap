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

ActiveRecord::Schema.define(version: 20170516184429) do

  create_table "annotations", force: :cascade do |t|
    t.integer  "question_id", limit: 4
    t.integer  "org_id",      limit: 4
    t.text     "text",        limit: 65535
    t.integer  "type",        limit: 4,     default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "annotations", ["org_id"], name: "fk_rails_aca7521f72", using: :btree
  add_index "annotations", ["question_id"], name: "fk_rails_0e08e753b6", using: :btree

  create_table "answers", force: :cascade do |t|
    t.text     "text",         limit: 65535
    t.integer  "plan_id",      limit: 4
    t.integer  "user_id",      limit: 4
    t.integer  "question_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version", limit: 4,     default: 0
  end

  add_index "answers", ["plan_id"], name: "fk_rails_84a6005a3e", using: :btree
  add_index "answers", ["question_id"], name: "fk_rails_3d5ed4418f", using: :btree
  add_index "answers", ["user_id"], name: "fk_rails_584be190c2", using: :btree

  create_table "answers_question_options", id: false, force: :cascade do |t|
    t.integer "answer_id",          limit: 4, null: false
    t.integer "question_option_id", limit: 4, null: false
  end

  add_index "answers_question_options", ["answer_id", "question_option_id"], name: "answer_question_option_index", using: :btree
  add_index "answers_question_options", ["question_option_id", "answer_id"], name: "question_option_answer_index", using: :btree

  create_table "exported_plans", force: :cascade do |t|
    t.integer  "plan_id",    limit: 4
    t.integer  "user_id",    limit: 4
    t.string   "format",     limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "phase_id",   limit: 4
  end

  create_table "file_types", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.string   "icon_name",     limit: 255
    t.integer  "icon_size",     limit: 4
    t.string   "icon_location", limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "file_uploads", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.string   "title",        limit: 255
    t.text     "description",  limit: 65535
    t.integer  "size",         limit: 4
    t.boolean  "published"
    t.string   "location",     limit: 255
    t.integer  "file_type_id", limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",           limit: 255, null: false
    t.integer  "sluggable_id",   limit: 4,   null: false
    t.string   "sluggable_type", limit: 40
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", unique: true, using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "guidance_groups", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.integer  "org_id",          limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.boolean  "optional_subset"
    t.boolean  "published"
  end

  add_index "guidance_groups", ["org_id"], name: "fk_rails_819c1dbbc7", using: :btree

  create_table "guidances", force: :cascade do |t|
    t.text     "text",              limit: 65535
    t.integer  "guidance_group_id", limit: 4
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "question_id",       limit: 4
    t.boolean  "published"
  end

  add_index "guidances", ["guidance_group_id"], name: "fk_rails_20d29da787", using: :btree

  create_table "identifier_schemes", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.string   "description",      limit: 255
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo_url",         limit: 255
    t.string   "user_landing_url", limit: 255
  end

  create_table "languages", force: :cascade do |t|
    t.string  "abbreviation",     limit: 255
    t.string  "description",      limit: 255
    t.string  "name",             limit: 255
    t.boolean "default_language"
  end

  create_table "notes", force: :cascade do |t|
    t.integer  "user_id",     limit: 4
    t.text     "text",        limit: 65535
    t.boolean  "archived"
    t.integer  "answer_id",   limit: 4
    t.integer  "archived_by", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notes", ["answer_id"], name: "fk_rails_907f8d48bf", using: :btree
  add_index "notes", ["user_id"], name: "fk_rails_7f2323ad43", using: :btree

  create_table "org_token_permissions", force: :cascade do |t|
    t.integer  "org_id",                   limit: 4
    t.integer  "token_permission_type_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "org_token_permissions", ["org_id"], name: "fk_rails_e1db1b22c5", using: :btree
  add_index "org_token_permissions", ["token_permission_type_id"], name: "fk_rails_2aa265f538", using: :btree

  create_table "orgs", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.string   "abbreviation",    limit: 255
    t.string   "target_url",      limit: 255
    t.string   "wayfless_entity", limit: 255
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.integer  "parent_id",       limit: 4
    t.boolean  "is_other"
    t.string   "sort_name",       limit: 255
    t.text     "banner_text",     limit: 65535
    t.string   "logo_file_name",  limit: 255
    t.integer  "region_id",       limit: 4
    t.integer  "language_id",     limit: 4
    t.string   "logo_uid",        limit: 255
    t.string   "logo_name",       limit: 255
    t.string   "contact_email",   limit: 255
    t.integer  "org_type",        limit: 4,     default: 0, null: false
  end

  add_index "orgs", ["language_id"], name: "fk_rails_5640112cab", using: :btree
  add_index "orgs", ["region_id"], name: "fk_rails_5a6adf6bab", using: :btree

  create_table "perms", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "perms", ["name"], name: "index_perms_on_name", using: :btree
  add_index "perms", ["name"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree

  create_table "phases", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.text     "description", limit: 65535
    t.integer  "number",      limit: 4
    t.integer  "template_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug",        limit: 255
    t.boolean  "modifiable"
  end

  add_index "phases", ["template_id"], name: "index_phases_on_template_id", using: :btree

  create_table "plans", force: :cascade do |t|
    t.string   "title",                             limit: 255
    t.integer  "template_id",                       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug",                              limit: 255
    t.string   "grant_number",                      limit: 255
    t.string   "identifier",                        limit: 255
    t.text     "description",                       limit: 65535
    t.string   "principal_investigator",            limit: 255
    t.string   "principal_investigator_identifier", limit: 255
    t.string   "data_contact",                      limit: 255
    t.string   "funder_name",                       limit: 255
    t.integer  "visibility",                        limit: 4,     default: 0, null: false
  end

  add_index "plans", ["template_id"], name: "index_plans_on_template_id", using: :btree

  create_table "plans_guidance_groups", force: :cascade do |t|
    t.integer "guidance_group_id", limit: 4
    t.integer "plan_id",           limit: 4
  end

  add_index "plans_guidance_groups", ["guidance_group_id"], name: "fk_rails_ec1c5524d7", using: :btree
  add_index "plans_guidance_groups", ["plan_id"], name: "fk_rails_13d0671430", using: :btree

  create_table "question_formats", force: :cascade do |t|
    t.string   "title",        limit: 255
    t.text     "description",  limit: 65535
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.boolean  "option_based",               default: false
    t.integer  "formattype",   limit: 4,     default: 0
  end

  create_table "question_options", force: :cascade do |t|
    t.integer  "question_id", limit: 4
    t.string   "text",        limit: 255
    t.integer  "number",      limit: 4
    t.boolean  "is_default"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "question_options", ["question_id"], name: "fk_rails_b9c5f61cf9", using: :btree

  create_table "questions", force: :cascade do |t|
    t.text     "text",                   limit: 65535
    t.text     "default_value",          limit: 65535
    t.integer  "number",                 limit: 4
    t.integer  "section_id",             limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "question_format_id",     limit: 4
    t.boolean  "option_comment_display",               default: true
    t.boolean  "modifiable"
  end

  add_index "questions", ["question_format_id"], name: "fk_rails_4fbc38c8c7", using: :btree
  add_index "questions", ["section_id"], name: "index_questions_on_section_id", using: :btree

  create_table "questions_themes", id: false, force: :cascade do |t|
    t.integer "question_id", limit: 4, null: false
    t.integer "theme_id",    limit: 4, null: false
  end

  add_index "questions_themes", ["question_id", "theme_id"], name: "question_theme_index", using: :btree
  add_index "questions_themes", ["theme_id", "question_id"], name: "theme_question_index", using: :btree

  create_table "regions", force: :cascade do |t|
    t.string  "abbreviation",    limit: 255
    t.string  "description",     limit: 255
    t.string  "name",            limit: 255
    t.integer "super_region_id", limit: 4
  end

  create_table "roles", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "plan_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "access",     limit: 4, default: 0, null: false
  end

  add_index "roles", ["plan_id"], name: "fk_rails_a1ce6c2772", using: :btree
  add_index "roles", ["user_id"], name: "fk_rails_ab35d699f0", using: :btree

  create_table "sections", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.text     "description", limit: 65535
    t.integer  "number",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "published"
    t.integer  "phase_id",    limit: 4
    t.boolean  "modifiable"
  end

  add_index "sections", ["phase_id"], name: "index_sections_on_phase_id", using: :btree

  create_table "settings", force: :cascade do |t|
    t.string   "var",         limit: 255,   null: false
    t.text     "value",       limit: 65535
    t.integer  "target_id",   limit: 4,     null: false
    t.string   "target_type", limit: 255,   null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "settings", ["target_type", "target_id", "var"], name: "index_settings_on_target_type_and_target_id_and_var", unique: true, using: :btree

  create_table "splash_logs", force: :cascade do |t|
    t.string   "destination", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "templates", force: :cascade do |t|
    t.string   "title",            limit: 255
    t.text     "description",      limit: 65535
    t.boolean  "published"
    t.integer  "org_id",           limit: 4
    t.string   "locale",           limit: 255
    t.boolean  "is_default"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "version",          limit: 4
    t.integer  "visibility",       limit: 4
    t.integer  "customization_of", limit: 4
    t.integer  "dmptemplate_id",   limit: 4
    t.boolean  "migrated"
    t.boolean  "dirty",                          default: false
  end

  add_index "templates", ["org_id", "dmptemplate_id"], name: "template_organisation_dmptemplate_index", using: :btree
  add_index "templates", ["org_id"], name: "index_templates_on_org_id", using: :btree

  create_table "themes", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "locale",      limit: 255
  end

  create_table "themes_in_guidance", id: false, force: :cascade do |t|
    t.integer "theme_id",    limit: 4
    t.integer "guidance_id", limit: 4
  end

  add_index "themes_in_guidance", ["guidance_id"], name: "fk_rails_a5ab9402df", using: :btree
  add_index "themes_in_guidance", ["theme_id"], name: "fk_rails_7d708f6f1e", using: :btree

  create_table "token_permission_types", force: :cascade do |t|
    t.string   "token_type",       limit: 255
    t.text     "text_description", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_identifiers", force: :cascade do |t|
    t.string   "identifier",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",              limit: 4
    t.integer  "identifier_scheme_id", limit: 4
  end

  add_index "user_identifiers", ["identifier_scheme_id"], name: "fk_rails_fe95df7db0", using: :btree
  add_index "user_identifiers", ["user_id"], name: "fk_rails_65c9a98cdb", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "firstname",              limit: 255
    t.string   "surname",                limit: 255
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "orcid_id",               limit: 255
    t.string   "shibboleth_id",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encrypted_password",     limit: 255, default: ""
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "invitation_token",       limit: 255
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.string   "other_organisation",     limit: 255
    t.boolean  "accept_terms"
    t.integer  "org_id",                 limit: 4
    t.string   "api_token",              limit: 255
    t.integer  "invited_by_id",          limit: 4
    t.string   "invited_by_type",        limit: 255
    t.integer  "language_id",            limit: 4
    t.string   "recovery_email",         limit: 255
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["language_id"], name: "fk_rails_45f4f12508", using: :btree
  add_index "users", ["org_id"], name: "fk_rails_e73753bccb", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "users_perms", id: false, force: :cascade do |t|
    t.integer "user_id", limit: 4
    t.integer "perm_id", limit: 4
  end

  add_index "users_perms", ["perm_id"], name: "fk_rails_457217c31c", using: :btree
  add_index "users_perms", ["user_id", "perm_id"], name: "index_users_perms_on_user_id_and_perm_id", using: :btree

  add_foreign_key "annotations", "orgs"
  add_foreign_key "annotations", "questions"
  add_foreign_key "answers", "plans"
  add_foreign_key "answers", "questions"
  add_foreign_key "answers", "users"
  add_foreign_key "answers_question_options", "answers"
  add_foreign_key "answers_question_options", "question_options"
  add_foreign_key "guidance_groups", "orgs"
  add_foreign_key "guidances", "guidance_groups"
  add_foreign_key "notes", "answers"
  add_foreign_key "notes", "users"
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
  add_foreign_key "roles", "plans"
  add_foreign_key "roles", "users"
  add_foreign_key "sections", "phases"
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
