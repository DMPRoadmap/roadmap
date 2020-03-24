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

class Fragment::Dmp < StructuredAnswer

    def cost
        Fragment::Cost.where("(data->>'dmp')::int = ?", id)
    end

    def meta
        Fragment::Meta.where("(data->>'dmp')::int = ?", id)
    end

    def project
        Fragment::Project.where("(data->>'dmp')::int = ?", id)
    end

    def researchOutputs
        Fragment::ResearchOutput.where("(data->>'dmp')::int = ?", id)
    end

end
