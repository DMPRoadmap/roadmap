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
#  parent_id                 :integer
#
# Indexes
#
#  index_structured_answers_on_answer_id                  (answer_id)
#  index_structured_answers_on_structured_data_schema_id  (structured_data_schema_id)
#

class Fragment::Project < StructuredAnswer
    belongs_to :dmp, class_name: 'Fragment::Dmp'
    belongs_to :principal_investigator, class_name: 'Fragment::Person'
    
    has_many :funders, class_name: 'Fragment::Funder', foreign_key: 'parent_id' 
    has_many :partners, class_name: 'Fragment::Partner', foreign_key: 'parent_id' 
end
