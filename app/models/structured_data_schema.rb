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
#  class_name :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_structured_data_schemas_on_org_id  (org_id)
#

class StructuredDataSchema < ActiveRecord::Base
  belongs_to :org
  has_many :structured_answers
  has_many :questions


  def detailed_name 
    label + " ( " + name + "_V" + version.to_s + " )"
  end
end
