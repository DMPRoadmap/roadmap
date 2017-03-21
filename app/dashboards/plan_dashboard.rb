require "administrate/base_dashboard"

class PlanDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    template: Field::BelongsTo,
    phases: Field::HasMany,
    sections: Field::HasMany,
    questions: Field::HasMany,
    themes: Field::HasMany,
    answers: Field::HasMany,
    notes: Field::HasMany,
    roles: Field::HasMany,
    users: Field::HasMany,
    plan_guidance_groups: Field::HasMany,
    guidance_groups: Field::HasMany,
    exported_plans: Field::HasMany,
    setting_objects: Field::HasMany.with_options(class_name: "Settings::Template"),
    id: Field::Number,
    project_id: Field::Number,
    title: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    slug: Field::String,
    grant_number: Field::String,
    identifier: Field::String,
    description: Field::Text,
    principal_investigator: Field::String,
    principal_investigator_identifier: Field::String,
    data_contact: Field::String,
    funder_name: Field::String,
    visibility: Field::String.with_options(searchable: false),
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :template,
    :phases,
    :sections,
    :questions,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :template,
    :phases,
    :sections,
    :questions,
    :themes,
    :answers,
    :notes,
    :roles,
    :users,
    :plan_guidance_groups,
    :guidance_groups,
    :exported_plans,
    :setting_objects,
    :id,
    :project_id,
    :title,
    :created_at,
    :updated_at,
    :slug,
    :grant_number,
    :identifier,
    :description,
    :principal_investigator,
    :principal_investigator_identifier,
    :data_contact,
    :funder_name,
    :visibility,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :template,
    :phases,
    :sections,
    :questions,
    :themes,
    :answers,
    :notes,
    :roles,
    :users,
    :plan_guidance_groups,
    :guidance_groups,
    :exported_plans,
    :setting_objects,
    :project_id,
    :title,
    :slug,
    :grant_number,
    :identifier,
    :description,
    :principal_investigator,
    :principal_investigator_identifier,
    :data_contact,
    :funder_name,
    :visibility,
  ].freeze

  # Overwrite this method to customize how plans are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(plan)
  #   "Plan ##{plan.id}"
  # end
end
