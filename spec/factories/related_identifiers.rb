# frozen_string_literal: true

# == Schema Information
#
# Table name: related_identifiers
#
#  id                   :bigint(8)        not null, primary key
#  identifiable_type    :string(255)
#  identifier_type      :integer          not null
#  relation_type        :integer          not null
#  value                :string(255)      not null
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
FactoryBot.define do
  factory :related_identifier do
=begin
    identifier_scheme
    identifier_type        { RelatedIdentifier.relations_types.keys.sample }
    relation_type          { RelatedIdentifier.relation_types.keys.sample }

    trait :for_plan do
      association :identifiable, factory: :plan
    end
    trait :for_research_output do
      association :identifiable, factory: :research_output
    end
=end
  end
end
