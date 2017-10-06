require "administrate/base_dashboard"

class IdentifierSchemeDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    user_identifiers: Field::HasMany,
    users: Field::HasMany,
    id: Field::Number,
    name: Field::String,
    description: Field::String,
    active: Field::Boolean,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :name,
    :description,
    :user_identifiers,
    :users,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :user_identifiers,
    :users,
    :id,
    :name,
    :description,
    :active,
    :created_at,
    :updated_at,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :user_identifiers,
    :users,
    :name,
    :description,
    :active,
  ].freeze

  # Overwrite this method to customize how identifier schemes are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(identifier_scheme)
  #   "IdentifierScheme ##{identifier_scheme.id}"
  # end

  def display_resource(identifier_scheme)
    identifier_scheme.description
  end

end
