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

class Fragment::Person < StructuredAnswer
    has_one :meta, class_name: 'Fragment::Meta', foreign_key: 'parent_id'
    has_one :project, class_name: 'Fragment::Project', foreign_key: 'parent_id'
    has_one :research_output, class_name: 'Fragment::ResearchOutput', foreign_key: 'parent_id'

end
