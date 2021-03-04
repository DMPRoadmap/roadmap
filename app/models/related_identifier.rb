# frozen_string_literal: true

# == Schema Information
#
# Table name: related_identifiers
#
#  id                   :bigint           not null, primary key
#  identifiable_type    :string
#  value                :string           not null
#  identifier_type      :integer          not null
#  relation_type        :integer          not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  identifiable_id      :bigint
#  identifier_scheme_id :bigint
#
# Indexes
#
#  index_related_identifiers_on_identifier_scheme_id  (identifier_scheme_id)
#  index_related_identifiers_on_identifier_type       (identifier_type)
#  index_related_identifiers_on_relation_type         (relation_type)
#  index_relateds_on_identifiable_and_relation_type   (identifiable_id,identifiable_type,relation_type)
#
class RelatedIdentifier < ApplicationRecord

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
  enum identifier_type: %i[ARK arXiv bibcode DOI EAN13 EISSN Handle IGSN ISBN ISSN ISTC LISSN LSID
                           PMID PURL UPC URL URN w3id]

  enum relation_type: %i[IsCitedBy Cites
                         IsSupplementTo IsSupplementedBy
                         IsContinuedBy Continues
                         IsDescribedBy Describes
                         HasMetadata IsMetadataFor
                         HasVersion IsVersionOf IsNewVersionOf IsPreviousVersionOf
                         IsPartOf HasPart
                         IsReferencedBy References
                         IsDocumentedBy Documents
                         IsCompiledBy Compiles
                         IsVariantFormOf IsOriginalFormOf IsIdenticalTo
                         IsReviewedBy Reviews
                         IsDerivedFrom IsSourceOf
                         IsRequiredBy Requires
                         IsObsoletedBy Obsoletes]

end
