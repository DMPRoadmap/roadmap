require "administrate/base_dashboard"

class QuestionFormatDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    questions: Field::HasMany,
    id: Field::Number,
    title: Field::String,
    description: Field::Text,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    option_based: Field::Boolean,
    formattype: Field::String.with_options(searchable: false),
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :questions,
    :id,
    :title,
    :description,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :questions,
    :id,
    :title,
    :description,
    :created_at,
    :updated_at,
    :option_based,
    :formattype,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :questions,
    :title,
    :description,
    :option_based,
    :formattype,
  ].freeze

  # Overwrite this method to customize how question formats are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(question_format)
  #   "QuestionFormat ##{question_format.id}"
  # end
end
