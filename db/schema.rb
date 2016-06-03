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

ActiveRecord::Schema.define(version: 20160105114044) do

  create_table "answers", force: true do |t|
    t.text     "text"
    t.integer  "plan_id"
    t.integer  "user_id"
    t.integer  "question_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "answers_options", id: false, force: true do |t|
    t.integer "answer_id", null: false
    t.integer "option_id", null: false
  end

  add_index "answers_options", ["answer_id", "option_id"], name: "index_answers_options_on_answer_id_and_option_id", using: :btree

  create_table "comments", force: true do |t|
    t.integer  "user_id"
    t.integer  "question_id"
    t.text     "text"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.boolean  "archived"
    t.integer  "plan_id"
    t.integer  "archived_by"
  end

  create_table "dmptemplates", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.boolean  "published"
    t.integer  "user_id"
    t.integer  "organisation_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "locale"
    t.boolean  "is_default"
  end

  create_table "dmptemplates_guidance_groups", id: false, force: true do |t|
    t.integer "dmptemplate_id"
    t.integer "guidance_group_id"
  end

  create_table "exported_plans", force: true do |t|
    t.integer  "plan_id"
    t.integer  "user_id"
    t.string   "format"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "file_types", force: true do |t|
    t.string   "name"
    t.string   "icon_name"
    t.integer  "icon_size"
    t.string   "icon_location"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "file_uploads", force: true do |t|
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

  create_table "friendly_id_slugs", force: true do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 40
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", unique: true, using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "guidance_groups", force: true do |t|
    t.string   "name"
    t.integer  "organisation_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.boolean  "optional_subset"
    t.boolean  "published"
  end

  create_table "guidance_in_group", id: false, force: true do |t|
    t.integer "guidance_id",       null: false
    t.integer "guidance_group_id", null: false
  end

  add_index "guidance_in_group", ["guidance_id", "guidance_group_id"], name: "index_guidance_in_group_on_guidance_id_and_guidance_group_id", using: :btree

  create_table "guidances", force: true do |t|
    t.text     "text"
    t.integer  "guidance_group_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "question_id"
    t.boolean  "published"
  end

  create_table "option_warnings", force: true do |t|
    t.integer  "organisation_id"
    t.integer  "option_id"
    t.text     "text"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "options", force: true do |t|
    t.integer  "question_id"
    t.string   "text"
    t.integer  "number"
    t.boolean  "is_default"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "organisation_types", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "organisations", force: true do |t|
    t.string   "name"
    t.string   "abbreviation"
    t.text     "description"
    t.string   "target_url"
    t.integer  "organisation_type_id"
    t.string   "domain"
    t.string   "wayfless_entity"
    t.integer  "stylesheet_file_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "parent_id"
    t.boolean  "is_other"
    t.string   "sort_name"
    t.text     "banner_text"
    t.string   "logo_file_name"
  end

  create_table "phases", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "number"
    t.integer  "dmptemplate_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "slug"
  end

  add_index "phases", ["dmptemplate_id"], name: "index_phases_on_dmptemplate_id", using: :btree
  add_index "phases", ["slug"], name: "index_phases_on_slug", unique: true, using: :btree

  create_table "plan_sections", force: true do |t|
    t.integer  "user_id"
    t.integer  "section_id"
    t.integer  "plan_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.datetime "release_time"
  end

  create_table "plans", force: true do |t|
    t.boolean  "locked"
    t.integer  "project_id"
    t.integer  "version_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "project_groups", force: true do |t|
    t.boolean  "project_creator"
    t.boolean  "project_editor"
    t.integer  "user_id"
    t.integer  "project_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.boolean  "project_administrator"
  end

  create_table "project_guidance", id: false, force: true do |t|
    t.integer "project_id",        null: false
    t.integer "guidance_group_id", null: false
  end

  add_index "project_guidance", ["project_id", "guidance_group_id"], name: "index_project_guidance_on_project_id_and_guidance_group_id", using: :btree

  create_table "projects", force: true do |t|
    t.string   "title"
    t.integer  "dmptemplate_id"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "slug"
    t.integer  "organisation_id"
    t.string   "grant_number"
    t.string   "identifier"
    t.text     "description"
    t.string   "principal_investigator"
    t.string   "principal_investigator_identifier"
    t.string   "data_contact"
    t.string   "funder_name"
  end

  add_index "projects", ["slug"], name: "index_projects_on_slug", unique: true, using: :btree

  create_table "question_formats", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "questions", force: true do |t|
    t.text     "text"
    t.text     "default_value"
    t.text     "guidance"
    t.integer  "number"
    t.integer  "parent_id"
    t.integer  "dependency_id"
    t.text     "dependency_text"
    t.integer  "section_id"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "question_format_id"
    t.boolean  "option_comment_display", default: true
  end

  create_table "questions_themes", id: false, force: true do |t|
    t.integer "question_id", null: false
    t.integer "theme_id",    null: false
  end

  add_index "questions_themes", ["question_id", "theme_id"], name: "index_questions_themes_on_question_id_and_theme_id", using: :btree

  create_table "roles", force: true do |t|
    t.string   "name"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.boolean  "role_in_plans"
    t.integer  "resource_id"
    t.string   "resource_type"
  end

  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree

  create_table "sections", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "number"
    t.integer  "version_id"
    t.integer  "organisation_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.boolean  "published"
  end

  create_table "settings", force: true do |t|
    t.string   "var",         null: false
    t.text     "value"
    t.integer  "target_id",   null: false
    t.string   "target_type", null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "settings", ["target_type", "target_id", "var"], name: "index_settings_on_target_type_and_target_id_and_var", unique: true, using: :btree

  create_table "splash_logs", force: true do |t|
    t.string   "destination"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "suggested_answers", force: true do |t|
    t.integer  "question_id"
    t.integer  "organisation_id"
    t.text     "text"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.boolean  "is_example"
  end

  create_table "themes", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "locale"
  end

  create_table "themes_in_guidance", id: false, force: true do |t|
    t.integer "theme_id"
    t.integer "guidance_id"
  end

  create_table "user_org_roles", force: true do |t|
    t.integer  "user_id"
    t.integer  "organisation_id"
    t.integer  "user_role_type_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "user_role_types", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "user_statuses", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "user_types", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "users", force: true do |t|
    t.string   "firstname"
    t.string   "surname"
    t.string   "email",                  default: "", null: false
    t.string   "orcid_id"
    t.string   "shibboleth_id"
    t.integer  "user_type_id"
    t.integer  "user_status_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
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
    t.boolean  "dmponline3"
    t.boolean  "accept_terms"
    t.integer  "organisation_id"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "users_roles", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

  create_table "versions", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.boolean  "published"
    t.integer  "number"
    t.integer  "phase_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "versions", ["phase_id"], name: "index_versions_on_phase_id", using: :btree

end
