require "administrate/base_dashboard"

class TokenPermissionTypeDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    orgs: Field::HasMany,
    id: Field::Number,
    token_type: Field::String,
    text_description: Field::Text,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :orgs,
    :id,
    :token_type,
    :text_description,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :orgs,
    :id,
    :token_type,
    :text_description,
    :created_at,
    :updated_at,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :orgs,
    :token_type,
    :text_description,
  ].freeze

  # Overwrite this method to customize how token permission types are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(token_permission_type)
  #   "TokenPermissionType ##{token_permission_type.id}"
  # end
  def display_resource(token_permission_type)
    "#{token_permission_type.token_type}: #{token_permission_type.text_description}"
  end

end
