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

class Fragment::ResearchOutput < StructuredAnswer
    
    def contact
        Fragment::Person.where(id: data['contact']['dbId']).first
    end
    
    def data_collection
        Fragment::DataCollection.where(parent_id: id).first
    end
    
    def data_quality
        Fragment::DataQuality.where(parent_id: id).first
    end

    def documentation 
        Fragment::Documentation.where(parent_id: id).first
    end

    def preservation_issue 
        Fragment::PreservationIssue.where(parent_id: id).first
    end

    def sharing 
        Fragment::Sharing.where(parent_id: id).first
    end



    def costs
        Fragment::Cost.where(parent_id: id)
    end

    def distributions
        Fragment::Distribution.where(parent_id: id)
    end

    def ethical_issues
        Fragment::EthicalIssue.where(parent_id: id)
    end

    def legal_issues
        Fragment::LegalIssue.where(parent_id: id)
    end


    def personal_data_issues
        Fragment::PersonalDataIssue.where(parent_id: id)
    end

    def reuse_datas
        Fragment::ReuseData.where(parent_id: id)
    end

    def staff_members
        Fragment::StaffMember.where(parent_id: id)
    end

    def technical_resource_usages
        Fragment::TechnicalResourceUsage.where(parent_id: id)
    end


    def self.sti_name
        "research_output"
    end
end
