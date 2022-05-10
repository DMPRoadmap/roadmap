# frozen_string_literal: true

# == Schema Information
#
# Table name: madmp_fragments

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
  # Budget STI model
  class Project < MadmpFragment
    def fundings
      Fragment::Funding.where(parent_id: id)
    end

    def partner
      Fragment::Partner.where(parent_id: id)
    end

    def experimental_plan
      Fragment::ResourceReference.where(parent_id: id).first
    end

    def principal_investigator
      Fragment::Contributor.where(parent_id: id).first
    end

    def properties
      'funding, partner, experimental_plan, principal_investigator'
    end

    def self.sti_name
      'project'
    end
  end
end
