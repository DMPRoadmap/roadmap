require "administrate/base_dashboard"

class ExportedPlanDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    plan: Field::BelongsTo,
    user: Field::BelongsTo,
    setting_objects: Field::HasMany.with_options(class_name: "Settings::Template"),
    id: Field::Number,
    format: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    phase_id: Field::Number,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :plan,
    :user,
    :setting_objects,
    :id,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :plan,
    :user,
    :setting_objects,
    :id,
    :format,
    :created_at,
    :updated_at,
    :phase_id,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :plan,
    :user,
    :setting_objects,
    :format,
    :phase_id,
  ].freeze

  # Overwrite this method to customize how exported plans are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(exported_plan)
  #   "ExportedPlan ##{exported_plan.id}"
  # end
end
