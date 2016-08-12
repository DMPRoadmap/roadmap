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
ActiveRecord::Schema.define(version: 20160810193149) do
  create_table "answers", force: :cascade do |t|
    t.text     "text",        limit: 65535
    t.integer  "plan_id",     limit: 4
    t.integer  "user_id",     limit: 4
    t.integer  "question_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "answers_options", id: false, force: :cascade do |t|
    t.integer "answer_id", limit: 4, null: false
    t.integer "option_id", limit: 4, null: false
  end

  add_index "answers_options", ["answer_id", "option_id"], name: "index_answers_options_on_answer_id_and_option_id", using: :btree

  create_table "comments", force: :cascade do |t|
    t.integer  "user_id",     limit: 4
    t.integer  "question_id", limit: 4
    t.text     "text",        limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "archived"
    t.integer  "plan_id",     limit: 4
    t.integer  "archived_by", limit: 4
  end

  create_table "dmptemplates", force: :cascade do |t|
    t.string   "title",           limit: 255
    t.text     "description",     limit: 65535
    t.boolean  "published"
    t.integer  "user_id",         limit: 4
    t.integer  "organisation_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "locale",          limit: 255
    t.boolean  "is_default"
  end

  create_table "dmptemplates_guidance_groups", id: false, force: :cascade do |t|
    t.integer "dmptemplate_id",    limit: 4
    t.integer "guidance_group_id", limit: 4
  end

  create_table "exported_plans", force: :cascade do |t|
    t.integer  "plan_id",    limit: 4
    t.integer  "user_id",    limit: 4
    t.string   "format",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "file_types", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.string   "icon_name",     limit: 255
    t.integer  "icon_size",     limit: 4
    t.string   "icon_location", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "file_uploads", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.string   "title",        limit: 255
    t.text     "description",  limit: 65535
    t.integer  "size",         limit: 4
    t.boolean  "published"
    t.string   "location",     limit: 255
    t.integer  "file_type_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",           limit: 191, null: false
    t.integer  "sluggable_id",   limit: 4,   null: false
    t.string   "sluggable_type", limit: 40
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", unique: true, using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "guidance_groups", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.integer  "organisation_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "optional_subset"
    t.boolean  "published"
  end

  create_table "guidance_in_group", id: false, force: :cascade do |t|
    t.integer "guidance_id",       limit: 4, null: false
    t.integer "guidance_group_id", limit: 4, null: false
  end

  add_index "guidance_in_group", ["guidance_id", "guidance_group_id"], name: "index_guidance_in_group_on_guidance_id_and_guidance_group_id", using: :btree

  create_table "guidances", force: :cascade do |t|
    t.text     "text",              limit: 65535
    t.integer  "guidance_group_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "question_id",       limit: 4
    t.boolean  "published"
  end

  create_table "languages", force: :cascade do |t|
    t.string  "abbreviation",     limit: 255
    t.string  "description",      limit: 255
    t.string  "name",             limit: 255
    t.boolean "default_language"
  end

  create_table "option_warnings", force: :cascade do |t|
    t.integer  "organisation_id", limit: 4
    t.integer  "option_id",       limit: 4
    t.text     "text",            limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "options", force: :cascade do |t|
    t.integer  "question_id", limit: 4
    t.string   "text",        limit: 255
    t.integer  "number",      limit: 4
    t.boolean  "is_default"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "org_token_permissions", force: :cascade do |t|
    t.integer  "organisation_id",          limit: 4
    t.integer  "token_permission_type_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organisation_types", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organisations", force: :cascade do |t|
    t.string   "name",                 limit: 255
    t.string   "abbreviation",         limit: 255
    t.text     "description",          limit: 65535
    t.string   "target_url",           limit: 255
    t.integer  "organisation_type_id", limit: 4
    t.string   "domain",               limit: 255
    t.string   "wayfless_entity",      limit: 255
    t.integer  "stylesheet_file_id",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id",            limit: 4
    t.boolean  "is_other"
    t.string   "sort_name",            limit: 255
    t.text     "banner_text",          limit: 65535
    t.string   "logo_file_name",       limit: 255
    t.integer  "region_id",            limit: 4
    t.integer  "language_id",          limit: 4
    t.string   "logo_uid",             limit: 255
    t.string   "logo_name",            limit: 255
  end

  create_table "phases", force: :cascade do |t|
    t.string   "title",          limit: 255
    t.text     "description",    limit: 65535
    t.integer  "number",         limit: 4
    t.integer  "dmptemplate_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug",           limit: 191
  end

  add_index "phases", ["dmptemplate_id"], name: "index_phases_on_dmptemplate_id", using: :btree
  add_index "phases", ["slug"], name: "index_phases_on_slug", unique: true, using: :btree

  create_table "plan_sections", force: :cascade do |t|
    t.integer  "user_id",      limit: 4
    t.integer  "section_id",   limit: 4
    t.integer  "plan_id",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "release_time"
  end

  create_table "plans", force: :cascade do |t|
    t.boolean  "locked"
    t.integer  "project_id", limit: 4
    t.integer  "version_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "project_groups", force: :cascade do |t|
    t.boolean  "project_creator"
    t.boolean  "project_editor"
    t.integer  "user_id",               limit: 4
    t.integer  "project_id",            limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "project_administrator"
  end

  create_table "project_guidance", id: false, force: :cascade do |t|
    t.integer "project_id",        limit: 4, null: false
    t.integer "guidance_group_id", limit: 4, null: false
  end

  add_index "project_guidance", ["project_id", "guidance_group_id"], name: "index_project_guidance_on_project_id_and_guidance_group_id", using: :btree

  create_table "projects", force: :cascade do |t|
    t.string   "title",                             limit: 255
    t.integer  "dmptemplate_id",                    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug",                              limit: 191
    t.integer  "organisation_id",                   limit: 4
    t.string   "grant_number",                      limit: 255
    t.string   "identifier",                        limit: 255
    t.text     "description",                       limit: 65535
    t.string   "principal_investigator",            limit: 255
    t.string   "principal_investigator_identifier", limit: 255
    t.string   "data_contact",                      limit: 255
    t.string   "funder_name",                       limit: 255
  end

  add_index "projects", ["slug"], name: "index_projects_on_slug", unique: true, using: :btree

  create_table "question_formats", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "questions", force: :cascade do |t|
    t.text     "text",                   limit: 65535
    t.text     "default_value",          limit: 65535
    t.text     "guidance",               limit: 65535
    t.integer  "number",                 limit: 4
    t.integer  "parent_id",              limit: 4
    t.integer  "dependency_id",          limit: 4
    t.text     "dependency_text",        limit: 65535
    t.integer  "section_id",             limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "question_format_id",     limit: 4
    t.boolean  "option_comment_display",               default: true
  end

  create_table "questions_themes", id: false, force: :cascade do |t|
    t.integer "question_id", limit: 4, null: false
    t.integer "theme_id",    limit: 4, null: false
  end

  add_index "questions_themes", ["question_id", "theme_id"], name: "index_questions_themes_on_question_id_and_theme_id", using: :btree

  create_table "region_groups", force: :cascade do |t|
    t.integer "super_region_id", limit: 4
    t.integer "region_id",       limit: 4
  end

  create_table "regions", force: :cascade do |t|
    t.string "abbreviation", limit: 255
    t.string "description",  limit: 255
    t.string "name",         limit: 255
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name",          limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "role_in_plans"
    t.integer  "resource_id",   limit: 4
    t.string   "resource_type", limit: 255
  end

  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree

  create_table "sections", force: :cascade do |t|
    t.string   "title",           limit: 255
    t.text     "description",     limit: 65535
    t.integer  "number",          limit: 4
    t.integer  "version_id",      limit: 4
    t.integer  "organisation_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "published"
  end

  create_table "settings", force: :cascade do |t|
    t.string   "var",         limit: 191,   null: false
    t.text     "value",       limit: 65535
    t.integer  "target_id",   limit: 4,     null: false
    t.string   "target_type", limit: 191,   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["target_type", "target_id", "var"], name: "index_settings_on_target_type_and_target_id_and_var", unique: true, using: :btree

  create_table "splash_logs", force: :cascade do |t|
    t.string   "destination", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "suggested_answers", force: :cascade do |t|
    t.integer  "question_id",     limit: 4
    t.integer  "organisation_id", limit: 4
    t.text     "text",            limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_example"
  end

  create_table "themes", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "locale",      limit: 255
  end

  create_table "themes_in_guidance", id: false, force: :cascade do |t|
    t.integer "theme_id",    limit: 4
    t.integer "guidance_id", limit: 4
  end

  create_table "token_permission_types", force: :cascade do |t|
    t.string   "token_type",      limit: 255
    t.text     "text_desription", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_org_roles", force: :cascade do |t|
    t.integer  "user_id",           limit: 4
    t.integer  "organisation_id",   limit: 4
    t.integer  "user_role_type_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_role_types", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_statuses", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_types", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "firstname",              limit: 255
    t.string   "surname",                limit: 255
    t.string   "email",                  limit: 191, default: "", null: false
    t.string   "orcid_id",               limit: 255
    t.string   "shibboleth_id",          limit: 255
    t.integer  "user_type_id",           limit: 4
    t.integer  "user_status_id",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encrypted_password",     limit: 255, default: ""
    t.string   "reset_password_token",   limit: 191
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "confirmation_token",     limit: 191
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "invitation_token",       limit: 191
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.string   "other_organisation",     limit: 255
    t.boolean  "dmponline3"
    t.boolean  "accept_terms"
    t.integer  "organisation_id",        limit: 4
    t.string   "api_token",              limit: 255
    t.integer  "invited_by_id",          limit: 4
    t.string   "invited_by_type",        limit: 255
    t.integer  "language_id",            limit: 4
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id", limit: 4
    t.integer "role_id", limit: 4
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.text     "description", limit: 65535
    t.boolean  "published"
    t.integer  "number",      limit: 4
    t.integer  "phase_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "versions", ["phase_id"], name: "index_versions_on_phase_id", using: :btree

end
