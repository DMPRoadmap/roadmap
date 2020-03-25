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

class Fragment::Project < StructuredAnswer

    def dmp
        Fragment::Dmp.where(id: data['dmp']).first
    end

    def principalInvestigator
        Fragment::Person.where(id: data['principalInvestigator']).first
    end


    
    def funders
        Fragment::Funder.where("(data->>'project')::int = ?", id)
    end

    def partners
        Fragment::Partner.where("(data->>'project')::int = ?", id)
    end

    
end
