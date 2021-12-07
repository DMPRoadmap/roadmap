# frozen_string_literal: true

# == Schema Information
#
# Table name: related_identifiers
#
#  id                   :bigint(8)        not null, primary key
#  identifiable_type    :string(255)
#  identifier_type      :integer          not null
#  relation_type        :integer          not null
#  work_type            :integer          not null
#  value                :string(255)      not null
#  citation             :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  identifiable_id      :bigint(8)
#  identifier_scheme_id :bigint(8)
#
# Indexes
#
#  index_related_identifiers_on_identifier_scheme_id  (identifier_scheme_id)
#  index_related_identifiers_on_identifier_type       (identifier_type)
#  index_related_identifiers_on_relation_type         (relation_type)
#  index_relateds_on_identifiable_and_relation_type   (identifiable_id,identifiable_type,relation_type)
#
class RelatedIdentifier < ApplicationRecord
  include Uc3Citation

  URL_REGEX = /^http/.freeze
  DOI_REGEX = %r{(doi:)?10\.[0-9]+/[a-zA-Z0-9.\-/]+}.freeze
  ARK_REGEX = %r{ark:[a-zA-Z0-9]+/[a-zA-Z0-9]+}.freeze

  # ================
  # = Associations =
  # ================

  belongs_to :identifiable, polymorphic: true, touch: true

  belongs_to :identifier_scheme, optional: true

  # ===============
  # = Validations =
  # ===============

  validates :value, presence: { message: PRESENCE_MESSAGE }

  validates :identifiable, presence: { message: PRESENCE_MESSAGE }

  # =========
  # = Enums =
  # =========

  # Broad categories to identify the type of work the related identifier represents
  enum work_type: %i[article dataset preprint software supplemental_information paper book]

  # The type of identifier based on the DataCite metadata schema
  enum identifier_type: %i[ark arxiv bibcode doi ean13 eissn handle igsn isbn issn istc
                           lissn lsid pmid purl upc url urn w3id other]

  # The relationship type between the related item and the Plan
  # Note that the 'references' value is changed to 'does_reference' in this list
  # because 'references' conflicts with an ActiveRecord method
  enum relation_type: %i[is_cited_by cites
                         is_supplement_to is_supplemented_by
                         is_continued_by continues
                         is_described_by describes
                         has_metadata is_metadata_for
                         has_version is_version_of is_new_version_of is_previous_version_of
                         is_part_of has_part
                         is_referenced_by does_reference
                         is_documented_by documents
                         is_compiled_by compiles
                         is_variant_form_of is_original_form_of is_identical_to
                         is_reviewed_by reviews
                         is_derived_from is_source_of
                         is_required_by requires
                         is_obsoleted_by obsoletes]

  # =============
  # = CALLBACKS =
  # =============

  before_validation :ensure_defaults

  # If we've enabled citation lookups, then try to fetch the citation after its created
  # or the value has changed
  after_save :load_citation

  # Returns the value sans the identifier scheme's prefix.
  # For example:
  #   value   'https://orcid.org/0000-0000-0000-0001'
  #   becomes '0000-0000-0000-0001'
  def value_without_scheme_prefix
    return value unless identifier_scheme.present? &&
                        identifier_scheme.identifier_prefix.present?

    base = identifier_scheme.identifier_prefix
    value.gsub(base, '').sub(%r{^/}, '')
  end

  private

  def ensure_defaults
    self.identifier_type = detect_identifier_type
    self.relation_type = detect_relation_type
  end

  def detect_identifier_type
    return 'ark' unless (value =~ ARK_REGEX).nil?
    return 'doi' unless (value =~ DOI_REGEX).nil?
    return 'url' unless (value =~ URL_REGEX).nil?

    'other'
  end

  def detect_relation_type
    relation_type.present? ? relation_type : 'cites'
  end

  def load_citation
    # Only attempt to load the citation if that functionality has been enabled in the
    # config, this is a DOI and its either a new record or the value has changed
    if Rails.configuration.x.madmp.enable_citation_lookup && identifier_type == 'doi' &&
       citation.nil?
      wrk_type = work_type == 'supplemental_information' ? '' : work_type
      # Use the UC3Citation service to fetch the citation for the DOI
      self.citation = fetch_citation(doi: value, work_type: wrk_type) # , debug: true)
    end
  end
end
