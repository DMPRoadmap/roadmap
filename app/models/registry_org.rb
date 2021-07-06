# frozen_string_literal: true

# == Schema Information
#
# Table name: registry_orgs
#
#  id                     :integer          not null, primary key
#  org_id                 :bigint(8)
#  ror_id                 :string(255)
#  funder_id              :string(255)
#  name                   :string(255)
#  homepage               :string(255)
#  language               :string(255)
#  types                  :json
#  acronyms               :json
#  aliases                :json
#  country                :json
#  file_timestamp         :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_registry_orgs_on_ror_id          (ror_id)
#  index_registry_orgs_on_funddref_id     (fundref_id)
#  index_registry_orgs_on_name            (name)
#  index_registry_orgs_on_file_timestamp  (file_timestamp)
#
# Foreign Keys
#
#  fk_rails_...  (org_id => orgs.id)
#
class RegistryOrg < ApplicationRecord

  # ================
  # = Associations =
  # ================

  belongs_to :org, optional: true

  # ==========
  # = Scopes =
  # ==========

  scope :by_acronym, lambda { |term|
    where("LOWER(registry_orgs.acronyms) LIKE LOWER(?)", "%\"#{term}\"%")
  }

  scope :by_alias, lambda { |term|
    where("LOWER(registry_orgs.aliases) LIKE LOWER(?)", "%#{term}%")
  }

  scope :by_name, lambda { |term|
    where("LOWER(registry_orgs.name) LIKE LOWER(?)", "%#{term}%")
  }

  scope :by_type, lambda { |term|
    where("LOWER(registry_orgs.types) LIKE LOWER(?)", "%#{term}%")
  }

  # Get all of the RegistryOrg entries that have been connected to another object (e.g. Plan, User, etc.)
  scope :known, lambda {
    where.not(org_id: nil)
  }

  # Get all of the RegistryOrg entries that have NOT been connected to another object (e.g. Plan, User, etc.)
  scope :unknown, lambda {
    where(org_id: nil)
  }

  scope :search, lambda { |term|
    results = by_name(term).or(by_acronym(term)).or(by_alias(term))
  }

  # ====================
  # = Instance methods =
  # ====================

  # Convert the record into a new Org
  def to_org
    return org if org.present?

    # If the record has a fundref id then it is a funder
    funder = fundref_id.present?
    # If the record is marked as Education then it is an institution
    institution = types.include?("Education")

    org = Org.new(
      name: name,
      contact_email: Rails.configuration.x.organisation.helpdesk_email,
      contact_name: _("%{app_name} helpdesk") % { app_name: ApplicationService.application_name },
      is_other: false,
      links: { "org": [{ "link": home_page, "text": "Home Page" }] },
      managed: false,
      target_url: home_page,
      funder: funder,
      institution: institution,
      organisation: !funder && !institution
    )
    org.abbreviation = acronyms.any? ? acronyms.first&.upcase : org.name_to_abbreviation
    org
  end

  private

  # Convert the fundref_id and ror_id into Identifier records to be attached to the associated Org
  def ror_or_fundref_to_identifier(scheme_name:, value:)
    return nil if org_id.present? && value.present? && scheme_name.present?

    scheme = IdentifierScheme.find_by(name: scheme_name)
    return nil unless scheme.present?

    Identifier.new(identifier_scheme: scheme, value: value)
  end

end
