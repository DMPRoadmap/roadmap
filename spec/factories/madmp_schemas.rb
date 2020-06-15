# == Schema Information
#
# Table name: madmp_schemas
#
#  id         :integer          not null, primary key
#  label      :string
#  name       :string
#  version    :integer
#  schema     :json
#  org_id     :integer
#  classname  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_madmp_schemas_on_org_id  (org_id)
#

FactoryBot.define do
  factory :madmp_schema do
    label { "MyString" }
    name { "MyString" }
    version { 1 }
    schema { "" }
    org
    classname { Faker::Company.bs }
  end
end
