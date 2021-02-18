# frozen_string_literal: true

# == Schema Information
#
# Table name: related_identifiers
#
#  id                   :bigint           not null, primary key
#  identifiable_type    :string
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

=begin
  ARKarXivbibcodeDOIEAN13EISSNHandleIGSNISBNISSNISTCLISSNLSIDPMIDPURLUPCURLURN w3id

  IsCitedByCitesIsSupplementToIsSupplementedByIsContinuedByContinuesIsDescribedByDescribesHasMetadataIsMetadataForHasVersionIsVersionOfIsNewVersionOfIsPreviousVersionOfIsPartOfHasPartIsReferencedByReferencesIsDocumentedByDocumentsIsCompiledByCompilesIsVariantFormOfIsOriginalFormOfIsIdenticalToIsReviewedByReviewsIsDerivedFromIsSourceOfIsRequiredBy RequiresIsObsoletedByObsoletes
=end
end
