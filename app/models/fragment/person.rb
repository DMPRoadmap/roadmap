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

class Fragment::Person < StructuredAnswer


    def documentations
        Fragment::Documentation.where("(data->>'documentation_administrator'->>'dbId')::int = ?", id)
    end

    def legal_issues
        Fragment::LegalIssue.where("(data->>'legal_advisor'->>'dbId')::int = ?", id)
    end

    def metas
        Fragment::Meta.where("(data->>'contact'->>'dbId')::int = ?", id)
    end

    def projects
        Fragment::Project.where("(data->>'principal_investigator'->>'dbId')::int = ?", id)
    end

    def research_outputs
        Fragment::ResearchOutput.where("(data->>'contact'->>'dbId')::int = ?", id)
    end

    def staff_members
        Fragment::StaffMember.where("(data->>'agent'->>'dbId')::int = ?", id)
    end

    
    def self.sti_name
        "person"
    end

end
