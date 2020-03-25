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
#
# Indexes
#
#  index_structured_answers_on_answer_id                  (answer_id)
#  index_structured_answers_on_structured_data_schema_id  (structured_data_schema_id)
#

class Fragment::LegalIssue < StructuredAnswer

    def legalAdvisor
        Fragment::Person.where(id: data['legalAdvisor']).first
    end

    def personalData
        Fragment::PersonalData.where(id: data['personalData']).first
    end

end
