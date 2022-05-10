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
  # ResearchOutputDescription STI model
  class ResearchOutputDescription < MadmpFragment
    def controlled_keyword
      Fragment::ControlledKeyword.where(parent_id: id)
    end

    def contact
      Fragment::Contributor.where(parent_id: id).first
    end

    def properties
      'controlled_keyword, contact'
    end

    def self.sti_name
      'research_output_description'
    end
  end
end
