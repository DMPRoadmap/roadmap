require "administrate/base_dashboard"

class QuestionDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    answers: Field::HasMany,
    question_options: Field::HasMany,
    annotations: Field::HasMany,
    themes: Field::HasMany,
    section: Field::BelongsTo,
    question_format: Field::BelongsTo,
    id: Field::Number,
    text: Field::Text,
    default_value: Field::Text,
    number: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    option_comment_display: Field::Boolean,
    modifiable: Field::Boolean,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :answers,
    :question_options,
    :annotations,
    :themes,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :answers,
    :question_options,
    :annotations,
    :themes,
    :section,
    :question_format,
    :id,
    :text,
    :default_value,
    :number,
    :created_at,
    :updated_at,
    :option_comment_display,
    :modifiable,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :answers,
    :question_options,
    :annotations,
    :themes,
    :section,
    :question_format,
    :text,
    :default_value,
    :number,
    :option_comment_display,
    :modifiable,
  ].freeze

  # Overwrite this method to customize how questions are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(question)
  #   "Question ##{question.id}"
  # end
end
