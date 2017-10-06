require "administrate/base_dashboard"

class PhaseDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    template: Field::BelongsTo,
    sections: Field::HasMany,
    questions: Field::HasMany,
    id: Field::Number,
    title: Field::String,
    description: Field::Text,
    number: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    slug: Field::String,
    modifiable: Field::Boolean,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :template,
    :sections,
    :questions,
    :id,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :template,
    :sections,
    :questions,
    :id,
    :title,
    :description,
    :number,
    :created_at,
    :updated_at,
    :slug,
    :modifiable,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :template,
    :sections,
    :questions,
    :title,
    :description,
    :number,
    :slug,
    :modifiable,
  ].freeze

  # Overwrite this method to customize how phases are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(phase)
  #   "Phase ##{phase.id}"
  # end
end
