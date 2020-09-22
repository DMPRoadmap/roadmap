# == Schema Information
#
# Table name: madmp_fragments
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
#
# Indexes
#
#  index_madmp_fragments_on_answer_id                  (answer_id)
#  index_madmp_fragments_on_madmp_schema_id  (madmp_schema_id)
#

class Fragment::ResearchOutput < MadmpFragment
    
    def contact
        Fragment::Person.where(id: data['contact']['dbId']).first
    end
    

    def description
        Fragment::ResearchOutputDescription.where(parent_id: id).first
    end

    def reuse_data
        Fragment::ReuseData.where(parent_id: id).first
    end

    def data_collection
        Fragment::DataCollection.where(parent_id: id).first
    end

    def ethical_issues
        Fragment::EthicalIssue.where(parent_id: id).first
    end

    def personal_data_issues
        Fragment::PersonalDataIssue.where(parent_id: id).first
    end

    def legal_issues
        Fragment::LegalIssue.where(parent_id: id).first
    end
    
    def data_processing
        Fragment::DataProcessing.where(parent_id: id).first
    end
    
    def data_storage
        Fragment::DataStorage.where(parent_id: id).first
    end

    def documentation_quality
        Fragment::DocumentationQuality.where(parent_id: id).first
    end

    def sharing 
        Fragment::Sharing.where(parent_id: id).first
    end

    def preservation_issue 
        Fragment::PreservationIssue.where(parent_id: id).first
    end




    def self.sti_name
        "research_output"
    end
end
