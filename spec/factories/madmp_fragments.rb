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

FactoryBot.define do
  factory :madmp_fragment do
    data { { } }
    classname { "dmp" }
    answer
    madmp_schema

    trait :data do 
      data { { } }
    end

    trait :classname do 
      classname { "dmp" }
    end
  end
end
