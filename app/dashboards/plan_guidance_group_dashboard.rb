require "administrate/base_dashboard"

class PlanGuidanceGroupDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    plan: Field::BelongsTo,
    guidance_group: Field::BelongsTo,
    id: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    selected: Field::Boolean,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :plan,
    :guidance_group,
    :id,
    :created_at,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :plan,
    :guidance_group,
    :id,
    :created_at,
    :updated_at,
    :selected,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :plan,
    :guidance_group,
    :selected,
  ].freeze

  # Overwrite this method to customize how plan guidance groups are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(plan_guidance_group)
  #   "PlanGuidanceGroup ##{plan_guidance_group.id}"
  # end
end
