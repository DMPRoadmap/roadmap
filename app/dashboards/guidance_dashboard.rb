require "administrate/base_dashboard"

class GuidanceDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    guidance_group: Field::BelongsTo,
    themes: Field::HasMany,
    id: Field::Number,
    text: Field::Text,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    question_id: Field::Number,
    published: Field::Boolean,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :guidance_group,
    :themes,
    :id,
    :text,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :guidance_group,
    :themes,
    :id,
    :text,
    :created_at,
    :updated_at,
    :question_id,
    :published,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :guidance_group,
    :themes,
    :text,
    :question_id,
    :published,
  ].freeze

  # Overwrite this method to customize how guidances are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(guidance)
  #   "Guidance ##{guidance.id}"
  # end
end
