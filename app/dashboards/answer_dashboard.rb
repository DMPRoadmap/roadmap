require "administrate/base_dashboard"

class AnswerDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    question: Field::BelongsTo,
    user: Field::BelongsTo,
    plan: Field::BelongsTo,
    notes: Field::HasMany,
    question_options: Field::HasMany,
    id: Field::Number,
    text: Field::Text,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    lock_version: Field::Number,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :question,
    :user,
    :plan,
    :notes,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :question,
    :user,
    :plan,
    :notes,
    :question_options,
    :id,
    :text,
    :created_at,
    :updated_at,
    :lock_version,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :question,
    :user,
    :plan,
    :notes,
    :question_options,
    :text,
    :lock_version,
  ].freeze

  # Overwrite this method to customize how answers are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(answer)
  #   "Answer ##{answer.id}"
  # end
end
