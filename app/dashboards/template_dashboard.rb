require "administrate/base_dashboard"

class TemplateDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    org: Field::BelongsTo,
    plans: Field::HasMany,
    phases: Field::HasMany,
    sections: Field::HasMany,
    questions: Field::HasMany,
    customizations: Field::HasMany.with_options(class_name: "Template"),
    dmptemplate: Field::BelongsTo.with_options(class_name: "Template"),
    setting_objects: Field::HasMany.with_options(class_name: "Settings::Template"),
    id: Field::Number,
    title: Field::String,
    description: Field::Text,
    published: Field::Boolean,
    locale: Field::String,
    is_default: Field::Boolean,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    version: Field::Number,
    visibility: Field::Number,
    customization_of: Field::Number,
    dmptemplate_id: Field::Number,
    migrated: Field::Boolean,
    dirty: Field::Boolean,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :title,
    :description,
    :org,
    :plans,
    :phases,
    :sections,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :org,
    :plans,
    :phases,
    :sections,
    :questions,
    :customizations,
    :dmptemplate,
    :setting_objects,
    :id,
    :title,
    :description,
    :published,
    :locale,
    :is_default,
    :created_at,
    :updated_at,
    :version,
    :visibility,
    :customization_of,
    :dmptemplate_id,
    :migrated,
    :dirty,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :org,
    :plans,
    :phases,
    :sections,
    :questions,
    :customizations,
    :dmptemplate,
    :setting_objects,
    :title,
    :description,
    :published,
    :locale,
    :is_default,
    :version,
    :visibility,
    :customization_of,
    :dmptemplate_id,
    :migrated,
    :dirty,
  ].freeze

  # Overwrite this method to customize how templates are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(template)
  #   "Template ##{template.id}"
  # end
end
