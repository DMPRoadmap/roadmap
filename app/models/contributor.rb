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

class Contributor < ActiveRecord::Base

  include FlagShihTzu
  include ValidationMessages
  include Identifiable

  # ================
  # = Associations =
  # ================

  # TODO: uncomment the 'optional' bit after the Rails 5 migration. Rails 5+ will
  #       NOT allow nil values in a belong_to field!
  belongs_to :org # , optional: true

  belongs_to :plan

  # =====================
  # = Nested attributes =
  # =====================

  accepts_nested_attributes_for :org

  # ===============
  # = Validations =
  # ===============

  validates :roles, presence: { message: PRESENCE_MESSAGE }

  validates :roles, numericality: { greater_than: 0,
                                    message: _("You must specify at least one role.") }

  validate :name_or_email_presence

  ONTOLOGY_NAME = "CRediT - Contributor Roles Taxonomy"
  ONTOLOGY_LANDING_PAGE = "https://casrai.org/credit/"
  ONTOLOGY_BASE_URL = "https://dictionary.casrai.org/Contributor_Roles"

  ##
  # Define Bit Field values for roles
  # Derived from the CASRAI CRediT Taxonomy: https://casrai.org/credit/
  has_flags 1 => :data_curation,
            2 => :investigation,
            3 => :project_administration,
            column: "roles"

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

  class << self

    # returns the default role
    def default_role
      "investigation"
    end

  end

  # ===================
  # = Private Methods =
  # ===================

  private

  def name_or_email_presence
    return true unless name.blank? && email.blank?

    errors.add(:name, _("can't be blank if no email is provided"))
    errors.add(:email, _("can't be blank if no name is provided"))
  end

end
