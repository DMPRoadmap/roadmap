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

class Fragment::LegalIssue < StructuredAnswer

    def legal_advisor
        Fragment::Person.where(id: data['legal_advisor']['dbId']).first
    end

    def research_output
        self.parent
    end

    
    def self.sti_name
        "legal_issue"
    end

end
