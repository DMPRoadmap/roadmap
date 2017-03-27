require "administrate/base_dashboard"

class UserDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    invited_by: Field::Polymorphic,
    perms: Field::HasMany,
    language: Field::BelongsTo,
    org: Field::BelongsTo,
    answers: Field::HasMany,
    notes: Field::HasMany,
    exported_plans: Field::HasMany,
    roles: Field::HasMany,
    plans: Field::HasMany,
    user_identifiers: Field::HasMany,
    identifier_schemes: Field::HasMany,
    setting_objects: Field::HasMany.with_options(class_name: "Settings::PlanList"),
    id: Field::Number,
    firstname: Field::String,
    surname: Field::String,
    email: Field::String,
    orcid_id: Field::String,
    shibboleth_id: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    encrypted_password: Field::String,
    reset_password_token: Field::String,
    reset_password_sent_at: Field::DateTime,
    remember_created_at: Field::DateTime,
    sign_in_count: Field::Number,
    current_sign_in_at: Field::DateTime,
    last_sign_in_at: Field::DateTime,
    current_sign_in_ip: Field::String,
    last_sign_in_ip: Field::String,
    confirmation_token: Field::String,
    confirmed_at: Field::DateTime,
    confirmation_sent_at: Field::DateTime,
    invitation_token: Field::String,
    invitation_created_at: Field::DateTime,
    invitation_sent_at: Field::DateTime,
    invitation_accepted_at: Field::DateTime,
    other_organisation: Field::String,
    dmponline3: Field::Boolean,
    accept_terms: Field::Boolean,
    api_token: Field::String,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :firstname,
    :surname,
    :email,
    :org,
    :perms,
    :confirmed_at,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :firstname,
    :surname,
    :email,
    :org,
    :perms,
    :confirmed_at,
    :id,
    :invited_by,
    :language,
    :answers,
    :notes,
    :exported_plans,
    :roles,
    :plans,
    :user_identifiers,
    :identifier_schemes,
    :setting_objects,
    :orcid_id,
    :shibboleth_id,
    :created_at,
    :updated_at,
    :encrypted_password,
    :reset_password_token,
    :reset_password_sent_at,
    :remember_created_at,
    :sign_in_count,
    :current_sign_in_at,
    :last_sign_in_at,
    :current_sign_in_ip,
    :last_sign_in_ip,
    :confirmation_token,
    :confirmation_sent_at,
    :invitation_token,
    :invitation_created_at,
    :invitation_sent_at,
    :invitation_accepted_at,
    :other_organisation,
    :dmponline3,
    :accept_terms,
    :api_token,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
#    :invited_by,
    :perms,
    :language,
    :org,
#    :answers,
#    :notes,
#    :exported_plans,
    :roles,
#    :plans,
    :user_identifiers,
    :identifier_schemes,
#    :setting_objects,
    :firstname,
    :surname,
    :email,
    :orcid_id,
    :shibboleth_id,
#    :encrypted_password,
    :reset_password_token,
    :reset_password_sent_at,
    :remember_created_at,
    :sign_in_count,
    :current_sign_in_at,
    :last_sign_in_at,
    :current_sign_in_ip,
    :last_sign_in_ip,
    :confirmation_token,
    :confirmed_at,
    :confirmation_sent_at,
    :invitation_token,
    :invitation_created_at,
    :invitation_sent_at,
    :invitation_accepted_at,
    :other_organisation,
    :dmponline3,
    :accept_terms,
    :api_token,
  ].freeze

  # Overwrite this method to customize how users are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(user)
  #   "User ##{user.id}"
  # end
end
