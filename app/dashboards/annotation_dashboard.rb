require "administrate/base_dashboard"

class AnnotationDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    org: Field::BelongsTo,
    question: Field::BelongsTo,
    id: Field::Number,
    text: Field::Text,
    type: Field::integer,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :org,
    :question,
    :id,
    :text,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :org,
    :question,
    :id,
    :text,
    :type,
    :created_at,
    :updated_at,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :org,
    :question,
    :text,
    :type,
  ].freeze

  # Overwrite this method to customize how suggested answers are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(suggested_answer)
  #   "SuggestedAnswer ##{suggested_answer.id}"
  # end
end
