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

class Fragment::Person < MadmpFragment


    def documentations
        Fragment::Documentation.where("(data->>'documentation_administrator'->>'dbid')::int = ?", id)
    end

    def legal_issues
        Fragment::LegalIssue.where("(data->>'legal_advisor'->>'dbid')::int = ?", id)
    end

    def metas
        Fragment::Meta.where("(data->>'contact'->>'dbid')::int = ?", id)
    end

    def projects
        Fragment::Project.where("(data->>'principal_investigator'->>'dbid')::int = ?", id)
    end

    def research_outputs
        Fragment::ResearchOutput.where("(data->>'contact'->>'dbid')::int = ?", id)
    end

    def staff_members
        Fragment::StaffMember.where("(data->>'agent'->>'dbid')::int = ?", id)
    end

    
    def self.sti_name
        "person"
    end

end
