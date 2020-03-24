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

class Fragment::ResearchOutput < StructuredAnswer
    
    def contact
        Fragment::Person.where(id: data['contact']).first
    end

    def dmp
        Fragment::Dmp.where(id: data['dmp']).first
    end

    def documentation 
        Fragment::Documentation.where("(data->>'research_output')::int = ?", id).first
    end

    def preservationIssue 
        Fragment::PreservationIssue.where("(data->>'research_output')::int = ?", id).first
    end

    def sharing 
        Fragment::Sharing.where("(data->>'research_output')::int = ?", id).first
    end

    def technicalResourceUsage 
        Fragment::TechnicalResourceUsage.where("(data->>'research_output')::int = ?", id).first
    end



    def distributions
        Fragment::Distribution.where("(data->>'research_output')::int = ?", id)
    end

    def ethicalIssues
        Fragment::EthicalIssue.where("(data->>'research_output')::int = ?", id)
    end

    def methodologyIssues
        Fragment::MethodologyIssue.where("(data->>'research_output')::int = ?", id)
    end

    def reuseDatas
        Fragment::ReuseData.where("(data->>'research_output')::int = ?", id)
    end

    def staffMembers
        Fragment::StaffMember.where("(data->>'research_output')::int = ?", id)
    end

end
