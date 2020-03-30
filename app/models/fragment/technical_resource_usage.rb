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

class Fragment::TechnicalResourceUsage < StructuredAnswer

    def backupPolicy
        Fragment::BackupPolicy.where(id: data['backup_policy']).first
    end

    def researchOutput
        Fragment::ResearchOutput.where(id: data['research_output']).first
    end

    def technicalResource
        Fragment::RechnicalResource.where(id: data['technical_resource']).first
    end

end
