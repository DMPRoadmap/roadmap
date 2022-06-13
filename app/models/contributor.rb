# frozen_string_literal: true

# == Schema Information
#
# Table name: contributors
#
#  id           :integer          not null, primary key
#  firstname    :string
#  surname      :string
#  email        :string
#  phone        :string
#  roles        :integer
#  org_id       :integer
#  plan_id      :integer
#  created_at   :datetime
#  updated_at   :datetime
#
# Indexes
#
#  index_contributors_on_id      (id)
#  index_contributors_on_email   (email)
#  index_contributors_on_org_id  (org_id)
#
# Foreign Keys
#
#  fk_rails_...  (org_id => orgs.id)
#  fk_rails_...  (plan_id => plans.id)

# Object that represents a contributor to a plan
class Contributor < ApplicationRecord
  include FlagShihTzu
  include ValidationMessages
  include Identifiable

  # ================
  # = Associations =
  # ================

  belongs_to :org, optional: true

  belongs_to :plan, optional: true

  # =====================
  # = Nested attributes =
  # =====================

  accepts_nested_attributes_for :org

  # ===============
  # = Validations =
  # ===============

  validates :roles, presence: { message: PRESENCE_MESSAGE }

  validates :roles, numericality: { greater_than: 0,
                                    message: _('You must specify at least one role.') }

  validate :name_or_email_presence

  ONTOLOGY_NAME = 'CRediT - Contributor Roles Taxonomy'
  ONTOLOGY_LANDING_PAGE = 'https://credit.niso.org/'
  ONTOLOGY_BASE_URL = 'http://credit.niso.org/contributor-roles/'

  ##
  # Define Bit Field values for roles
  # Derived from the CASRAI CRediT Taxonomy: http://credit.niso.org/contributor-roles/
  has_flags 1 => :data_curation,
            2 => :investigation,
            3 => :project_administration,
            4 => :other,
            column: 'roles',
            check_for_column: !Rails.env.test?

  # ==========
  # = Scopes =
  # ==========

  scope :search, lambda { |term|
    search_pattern = "%#{term}%"
    joins(:identifiers, :org)
      .where("lower(contributors.name) LIKE lower(:search_pattern)
              OR lower(contributors.email) LIKE lower(:search_pattern)
              OR lower(identifiers.value) LIKE lower(:search_pattern)
              OR lower(orgs.name) LIKE lower(:search_pattern)",
             search_pattern: search_pattern)
  }

  # ========================
  # = Static Class Methods =
  # ========================
  def self.role_default
    'other'
  end

  # Check for equality by matching on Plan, ORCID, email or name
  # rubocop:disable Metrics/CyclomaticComplexity
  def ==(other)
    return false unless other.is_a?(Contributor) && plan == other.plan

    current_orcid = identifier_for_scheme(scheme: 'orcid')&.value
    new_orcid = other.identifier_for_scheme(scheme: 'orcid')&.value

    email == other.email || name == other.name ||
      (current_orcid.present? && current_orcid == new_orcid)
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  # Merges the contents of the other Contributor into this one while retaining
  # any existing information
  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def merge(other)
    self.org = other.org unless org.present?
    self.email = other.email unless email.present?
    self.name = other.name unless name.present?
    self.phone = other.phone unless phone.present?
    self.investigation = true if other.investigation? && !investigation?
    self.data_curation = true if other.data_curation? && !data_curation?
    self.project_administration = true if other.project_administration? && !project_administration?
    consolidate_identifiers!(array: other.identifiers.to_a)
    self
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  # ===================
  # = Private Methods =
  # ===================

  private

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
  def name_or_email_presence
    errors.add(:name, _("can't be blank.")) if name.blank? && Rails.configuration.x.application.require_contributor_name
    if email.blank? && Rails.configuration.x.application.require_contributor_email
      errors.add(:email,
                 _("can't be blank."))
    end

    if name.blank? && email.blank? && errors.size.zero?
      errors.add(:name, _("can't be blank if no email is provided."))
      errors.add(:email, _("can't be blank if no name is provided."))
    end

    errors.size.zero?
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity
end
