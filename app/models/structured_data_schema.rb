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
#  classname  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_structured_data_schemas_on_org_id  (org_id)
#

class StructuredDataSchema < ActiveRecord::Base
  include ValidationMessages

  belongs_to :org
  has_many :structured_answers
  has_many :questions

  delegate :costs, 
           :dmps, 
           :funders,
           :metas,
           :partners,
           :persons,
           :projects,
           :research_outputs, to: :structured_answers


  validates :name, presence: { message: PRESENCE_MESSAGE },
                      uniqueness: { message: UNIQUENESS_MESSAGE }

  #validates :schema, presence:  { message: PRESENCE_MESSAGE },
  #                    json: true
                      
  def detailed_name 
    label + " ( " + name + "_V" + version.to_s + " )"
  end
  
end
