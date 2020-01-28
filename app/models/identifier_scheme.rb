# == Schema Information
#
# Table name: identifier_schemes
#
#  id               :integer          not null, primary key
#  active           :boolean
#  description      :string
#  logo_url         :text
#  name             :string
#  user_landing_url :text
#  created_at       :datetime
#  updated_at       :datetime
#

class IdentifierScheme < ActiveRecord::Base
  include ValidationMessages
  include ValidationValues

  ##
  # The maximum length for a name
  NAME_MAXIMUM_LENGTH = 30

  has_many :identifiers

  # ===============
  # = Validations =
  # ===============

  validates :name, uniqueness: { message: UNIQUENESS_MESSAGE },
                   presence: { message: PRESENCE_MESSAGE },
                   length: { maximum: NAME_MAXIMUM_LENGTH }

  validates :active, inclusion: { message: INCLUSION_MESSAGE,
                                  in: BOOLEAN_VALUES }

  # ===========================
  # = Scopes =
  # ===========================

  scope :active, -> { where(active: true) }
  scope :for_users, -> { active.where(name: %w[shibboleth orcid]) }
  scope :for_orgs, -> { active.where(name: %w[shibboleth ror fundref]) }
  scope :for_plans, -> { active.where(name: %w[doi]) }
  scope :authenticatable, -> { active.where(name: %w[shibboleth orcid]) }
  scope :by_name, ->(value) { active.where("LOWER(name) = LOWER(?)", value) }
end
