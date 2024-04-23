# frozen_string_literal: true

# == Schema Information
#
# Table name: madmp_fragments
#
#  id              :integer          not null, primary key
#  additional_info :json
#  classname       :string
#  data            :json
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  answer_id       :integer
#  dmp_id          :integer
#  madmp_schema_id :integer
#  parent_id       :integer
#
# Indexes
#
#  index_madmp_fragments_on_answer_id        (answer_id)
#  index_madmp_fragments_on_madmp_schema_id  (madmp_schema_id)
#
# Foreign Keys
#
#  fk_rails_...  (answer_id => answers.id)
#  fk_rails_...  (madmp_schema_id => madmp_schemas.id)
#

#  id                        :integer          not null, primary key
#  data                      :json
#  answer_id                 :integer
#  madmp_schema_id :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  classname                 :string
#  dmp_id                    :integer
#  parent_id                 :integer

# Indexes

#  index_madmp_fragments_on_answer_id                  (answer_id)
#  index_madmp_fragments_on_madmp_schema_id  (madmp_schema_id)
module Fragment
  # DocumentationQuality STI model
  class DocumentationQuality < MadmpFragment
    def data_organization
      Fragment::ResourceReference.where(parent_id: id)
    end

    def metadata_standard
      Fragment::MetadataStandard.where(parent_id: id)
    end

    def quality_assurance_method
      Fragment::QualityAssuranceMethod.where(parent_id: id)
    end

    def contributors
      Fragment::Contributor.where(parent_id: id)
    end

    def cost
      Fragment::Cost.where(parent_id: id)
    end

    def properties
      'data_organization, metadata_standard, quality_assurance_method, contributors, cost'
    end

    def self.sti_name
      'documentation_quality'
    end
  end
end
