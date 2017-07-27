require "administrate/base_dashboard"

class GuidanceGroupDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    org: Field::BelongsTo,
    guidances: Field::HasMany,
    plans: Field::HasMany,
    id: Field::Number,
    name: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    optional_subset: Field::Boolean,
    published: Field::Boolean,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :name,
    :org,
    :guidances,
#    :plans,
    :id,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :org,
    :guidances,
#    :plans,
    :id,
    :name,
    :created_at,
    :updated_at,
    :optional_subset,
    :published,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :org,
    :guidances,
#    :plans,
    :name,
    :optional_subset,
    :published,
  ].freeze

  # Overwrite this method to customize how guidance groups are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(guidance_group)
  #   "GuidanceGroup ##{guidance_group.id}"
  # end
  def display_resource(guidance_group)
    guidance_group.name
  end
end
