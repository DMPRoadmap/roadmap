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

class Fragment::Dmp < MadmpFragment

    def meta
        Fragment::Meta.where(dmp_id: id).first
    end

    def project
        Fragment::Project.where(dmp_id: id).first
    end

    def research_outputs
        Fragment::ResearchOutput.where(dmp_id: id)
    end

    def persons
        Fragment::Person.where(dmp_id: id)
    end


    def plan 
        Plan.find(data["plan_id"])
    end

    def self.sti_name
        "dmp"
    end
end
