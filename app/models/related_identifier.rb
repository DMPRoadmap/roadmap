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

  URL_REGEX = /^http/
  DOI_REGEX = %r{(doi:)?10\.[0-9]+/[a-zA-Z0-9.\-/]+}
  ARK_REGEX = %r{ark:[a-zA-Z0-9]+/[a-zA-Z0-9]+}

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
  enum work_type: { article: 0, dataset: 1, preprint: 2, software: 3, supplemental_information: 4,
                    paper: 5, book: 6, protocol: 7, preregistration: 8,
                    traditional_knowledge_labels_and_notices: 9 }

  # The type of identifier based on the DataCite metadata schema
  enum identifier_type: { ark: 0, arxiv: 1, bibcode: 2, doi: 3, ean13: 4, eissn: 5, handle: 6,
                          igsn: 7, isbn: 8, issn: 9, istc: 10, lissn: 11, lsid: 12, pmid: 13,
                          purl: 14, upc: 15, url: 16, urn: 17, w3id: 18, other: 19 }

  # The relationship type between the related item and the Plan
  # Note that the 'references' value is changed to 'does_reference' in this list
  # because 'references' conflicts with an ActiveRecord method
  enum relation_type: { is_cited_by: 0, cites: 1, is_supplement_to: 2, is_supplemented_by: 3,
                        is_continued_by: 4, continues: 5, is_described_by: 6, describes: 7,
                        has_metadata: 8, is_metadata_for: 9, has_version: 10, is_version_of: 11,
                        is_new_version_of: 12, is_previous_version_of: 13, is_part_of: 14,
                        has_part: 15, is_referenced_by: 16, does_reference: 17, is_documented_by: 18,
                        documents: 19, is_compiled_by: 20, compiles: 21, is_variant_form_of: 22,
                        is_original_form_of: 23, is_identical_to: 24, is_reviewed_by: 25, reviews: 26,
                        is_derived_from: 27, is_source_of: 28, is_required_by: 29, requires: 30,
                        is_obsoleted_by: 31, obsoletes: 32 }

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
    (relation_type.presence || 'cites')
  end

  def load_citation
    # Only attempt to load the citation if that functionality has been enabled in the
    # config, this is a DOI and its either a new record or the value has changed
    if Rails.configuration.x.madmp.enable_citation_lookup && identifier_type == 'doi' &&
       citation.nil?
      wrk_type = work_type == 'supplemental_information' ? '' : work_type
      # Use the UC3Citation service to fetch the citation for the DOI
      self.citation = fetch_citation(doi: value, work_type: wrk_type) # , debug: true)
      save
    end
  end
end
