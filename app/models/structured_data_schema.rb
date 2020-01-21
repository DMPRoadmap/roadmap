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

class StructuredDataSchema < ActiveRecord::Base
  belongs_to :org
  has_many :structured_answers
  has_many :questions
end
