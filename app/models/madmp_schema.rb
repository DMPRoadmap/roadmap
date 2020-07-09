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

class MadmpSchema < ActiveRecord::Base
  include ValidationMessages


  belongs_to :org
  has_many :madmp_fragments
  has_many :questions

  delegate :costs, 
           :dmps, 
           :funders,
           :metas,
           :partners,
           :persons,
           :projects,
           :research_outputs, to: :madmp_fragments


  validates :name, presence: { message: PRESENCE_MESSAGE },
                      uniqueness: { message: UNIQUENESS_MESSAGE }

  #validates :schema, presence:  { message: PRESENCE_MESSAGE },
  #                    json: true
       
  
  # =================
  # = Class Methods =
  # =================

  def detailed_name 
    label + " ( " + name + "_V" + version.to_s + " )"
  end

  def get_sub_schemas
    path = JsonPath.new('$..schema_id')
    ids = path.on(self.schema)
    MadmpSchema.where(id: ids).map { |s| [s.id, s] }.to_h
  end

  def generate_strong_params(flat = false)
    parameters = Array.new
    self.schema['properties'].each do |key, prop|
      if prop['type'] == "object" && prop['schema_id'].present?
        sub_schema = MadmpSchema.find(prop['schema_id'])
        parameters.append(sub_schema.classname => sub_schema.generate_strong_params(false))
      elsif prop['type'] == "array" && !flat
          parameters.append({key => []})
      else
          parameters.append(key)
      end
    end
    parameters
  end
  
end
