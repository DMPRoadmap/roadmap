# frozen_string_literal: true

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

  # validates :schema, presence:  { message: PRESENCE_MESSAGE },
  #                     json: true

  # ==========
  # = Constants =
  # ==========

  CLASSNAME_TO_PROPERTY = {
    "research_output_description" => "researchOutputDescription",
    "data_reuse" => "reuse",
    "personal_data_issues" => "personalDataIssues",
    "legal_issues" => "legalIssues",
    "ethical_issues" => "ethicalIssues",
    "data_collection" => "dataCollection",
    "data_processing" => "dataProcessing",
    "data_storage" => "dataStorage",
    "documentation_quality" => "documentationQuality",
    "quality_assurance_method" => "qualityAssuranceMethod",
    "data_sharing" => "sharing",
    "data_preservation" => "preservationIssues",
    "budget" => "budget"
  }

  # ==========
  # = Scopes =
  # ==========

  scope :search, ->(term) {
    search_pattern = "%#{term}%"
    where("lower(madmp_schemas.name) LIKE lower(?) OR " \
          "lower(madmp_schemas.classname) LIKE lower(?)",
          search_pattern, search_pattern)
  }

  # =================
  # = Class Methods =
  # =================

  def detailed_name
    label + " ( " + name + "_V" + version.to_s + " )"
  end

  def sub_schemas
    path = JsonPath.new("$..schema_id")
    ids = path.on(schema)
    MadmpSchema.where(id: ids).map { |s| [s.id, s] }.to_h
  end

  def sub_schemas_ids
    path = JsonPath.new("$..schema_id")
    ids = path.on(schema)
    ids
  end

  def generate_strong_params(flat = false)
    parameters = []
    schema["properties"].each do |key, prop|
      if prop["type"] == "object" && prop["schema_id"].present?
        if prop["inputType"].present? && prop["inputType"].eql?("pickOrCreate")
          parameters.append(key)
        elsif prop["registry_id"].present?
          parameters.append(key)
          parameters.append("#{key}_custom") if prop["overridable"].present?
        else
          sub_schema = MadmpSchema.find(prop["schema_id"])
          parameters.append(key => sub_schema.generate_strong_params(false))
        end
      elsif prop["type"] == "array" && !flat
        parameters.append(key => [])
      else
        parameters.append(key)
        parameters.append("#{key}_custom") if prop["overridable"].present?
      end
    end
    parameters
  end

  # Used by "Write Plan" tab for determining the property_name of a new fragment
  # from the classname of the corresponding schema
  def property_name_from_classname
    CLASSNAME_TO_PROPERTY[classname]
  end

  # Substitute 'template_name' key/values for their 'schema_id' equivalent in the JSON
  # and 'registry_name' key/values for their 'registry_id' equivalent in the JSON
  def self.substitute_names(json_schema)
    json_schema = JsonPath.for(json_schema).gsub("$..template_name") do |name|
      MadmpSchema.find_by!(name: name).id
    end.to_json.gsub("template_name", "schema_id")

    json_schema = JsonPath.for(json_schema).gsub("$..registry_name") do |name|
      Registry.find_by!(name: name).id
    end.to_json.gsub("registry_name", "registry_id")

    json_schema
  end

end
