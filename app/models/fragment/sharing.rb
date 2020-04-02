# == Schema Information
#
# Table name: structured_answers
#
#  id                        :integer          not null, primary key
#  data                      :json
#  answer_id                 :integer
#  structured_data_schema_id :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  classname                 :string
#  dmp_id                    :integer
#  parent_id                 :integer
#
# Indexes
#
#  index_structured_answers_on_answer_id                  (answer_id)
#  index_structured_answers_on_structured_data_schema_id  (structured_data_schema_id)
#

class Fragment::Sharing < StructuredAnswer

    def dmp
        Fragment::Dmp.where(id: dmp_id).first
    end

    def researchOutput
        Fragment::ResearchOutput.where(id: data['research_output'])
    end

    
    def self.sti_name
        "sharing"
    end

end
