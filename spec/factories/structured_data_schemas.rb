# == Schema Information
#
# Table name: structured_data_schemas
#
#  id         :integer          not null, primary key
#  label      :string
#  name       :string
#  version    :integer
#  schema     :json
#  org_id     :integer
#  object     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_structured_data_schemas_on_org_id  (org_id)
#

FactoryBot.define do
  factory :structured_data_schema do
    label { "MyString" }
    name { "MyString" }
    version { 1 }
    schema { "" }
    org_id { 1 }
    object { "MyString" }
  end
end
