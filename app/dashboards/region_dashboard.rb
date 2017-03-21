require "administrate/base_dashboard"

class RegionDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    sub_regions: Field::HasMany.with_options(class_name: "Region"),
    super_region: Field::BelongsTo.with_options(class_name: "Region"),
    id: Field::Number,
    abbreviation: Field::String,
    description: Field::String,
    name: Field::String,
    super_region_id: Field::Number,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :sub_regions,
    :super_region,
    :id,
    :abbreviation,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :sub_regions,
    :super_region,
    :id,
    :abbreviation,
    :description,
    :name,
    :super_region_id,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :sub_regions,
    :super_region,
    :abbreviation,
    :description,
    :name,
    :super_region_id,
  ].freeze

  # Overwrite this method to customize how regions are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(region)
  #   "Region ##{region.id}"
  # end
end
