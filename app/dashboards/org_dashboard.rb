require "administrate/base_dashboard"

class OrgDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    language: Field::BelongsTo,
    guidance_groups: Field::HasMany,
    templates: Field::HasMany,
    users: Field::HasMany,
    annotations: Field::HasMany,
    token_permission_types: Field::HasMany,
    id: Field::Number,
    name: Field::String,
    abbreviation: Field::String,
    target_url: Field::String,
    wayfless_entity: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    parent_id: Field::Number,
    is_other: Field::Boolean,
    sort_name: Field::String,
    banner_text: Field::Text,
    logo_file_name: Field::String,
    region_id: Field::Number,
    logo_uid: Field::String,
    logo_name: Field::String,
    contact_email: Field::String,
    org_type: Field::Number,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :name,
    :abbreviation,
    :language,
    :guidance_groups,
#    :templates,
    :contact_email,
    :org_type,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :name,
    :abbreviation,
    :language,
    :guidance_groups,
#    :templates,
    :contact_email,
    :org_type,
    :users,
    :annotations,
    :token_permission_types,
    :id,
    :target_url,
    :wayfless_entity,
    :created_at,
    :updated_at,
    :parent_id,
    :is_other,
    :sort_name,
    :banner_text,
    :logo_file_name,
    :region_id,
    :logo_uid,
    :logo_name,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :language,
    :guidance_groups,
#    :templates,
#    :users,
#    :annotations,
    :token_permission_types,
    :name,
    :abbreviation,
    :target_url,
    :wayfless_entity,
    :parent_id,
    :is_other,
    :sort_name,
    :banner_text,
    :logo_file_name,
    :region_id,
    :logo_uid,
    :logo_name,
    :contact_email,
    :org_type,
  ].freeze

  # Overwrite this method to customize how orgs are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(org)
  #   "Org ##{org.id}"
  # end

  def display_resource(org)
    org.name
  end
end
