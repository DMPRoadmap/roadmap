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
require "jsonpath"

class MadmpFragment < ActiveRecord::Base

  include ValidationMessages
  include DynamicFormHelper

  # ================
  # = Associations =
  # ================

  belongs_to :answer
  belongs_to :madmp_schema, class_name: "MadmpSchema"
  belongs_to :dmp, class_name: "Fragment::Dmp", foreign_key: "dmp_id"
  has_many :children, class_name: "MadmpFragment", foreign_key: "parent_id"
  belongs_to :parent, class_name: "MadmpFragment", foreign_key: "parent_id"

  # ===============
  # = Validations =
  # ===============

  #validates :madmp_schema, presence: { message: PRESENCE_MESSAGE }

  # ================
  # = Single Table Inheritence =
  # ================
  self.inheritance_column = :classname
  scope :backup_policies, -> { where(classname: "backup_policy") }
  scope :budgets, -> { where(classname: "budgets") }
  scope :contributors, -> { where(classname: "contributor") }
  scope :costs, -> { where(classname: "cost") }
  scope :data_collections, -> { where(classname: "data_collection") }
  scope :data_preservations, -> { where(classname: "data_preservation") }
  scope :data_processings, -> { where(classname: "data_processing") }
  scope :data_reuses, -> { where(classname: "data_reuse") }
  scope :data_sharings, -> { where(classname: "data_sharing") }
  scope :data_storages, -> { where(classname: "data_storage") }
  scope :distributions, -> { where(classname: "distribution") }
  scope :dmps, -> { where(classname: "dmp") }
  scope :documentation_qualities, -> { where(classname: "documentation_quality") }
  scope :ethical_issues, -> { where(classname: "ethical_issue") }
  scope :funders, -> { where(classname: "funder") }
  scope :fundings, -> { where(classname: "funding") }
  scope :legal_issues, -> { where(classname: "legal_issue") }
  scope :licences, -> { where(classname: "licence") }
  scope :metas, -> { where(classname: "meta") }
  scope :metadata_standards, -> { where(classname: "metadata_standard") }
  scope :partners, -> { where(classname: "partner") }
  scope :persons, -> { where(classname: "person") }
  scope :personal_data_issues, -> { where(classname: "personal_data_issue") }
  scope :projects, -> { where(classname: "project") }
  scope :research_outputs, -> { where(classname: "research_output") }
  scope :research_output_descriptions, -> { where(classname: "research_output_description") }
  scope :resource_references, -> { where(classname: "resource_reference") }
  scope :reused_datas, -> { where(classname: "reused_data") }
  scope :specific_datas, -> { where(classname: "specific_data") }
  scope :technical_resources, -> { where(classname: "technical_resource") }

  # =============
  # = Callbacks =
  # =============

  before_save   :set_defaults
  after_create  :update_parent_references
  after_destroy :update_parent_references

  # =====================
  # = Nested Attributes =
  # =====================
  accepts_nested_attributes_for :answer, allow_destroy: true

  # =================
  # = Class methods =
  # =================

  def plan
    if dmp.nil?
      Plan.find(data["plan_id"])
    else
      dmp.plan
    end
  end

  # Returns the schema associated to the JSON fragment
  def json_schema
    madmp_schema.schema
  end

  def get_dmp_fragments
    MadmpFragment.where(dmp_id: dmp.id)
  end

  # Returns a human readable version of the structured answer
  def to_s
    full_data = get_full_fragment
    displayable = ""
    if json_schema["to_string"]
      json_schema["to_string"].each do |pattern|
        # if it's a JsonPath pattern
        if pattern.first == "$"
          match = JsonPath.on(full_data, pattern)

          next if match.empty? || match.first.nil?

          if match.first.is_a?(Array)
            displayable += match.first.join("/")
          elsif match.first.is_a?(Integer)
            displayable += match.first.to_s
          else
            displayable += match.first
          end
        else
          displayable += pattern
        end
      end
    else
      displayable = full_data.to_s
    end
    displayable
  end

  # This method generates references to the child fragments in the parent fragment
  # it updates the json "data" field in the database
  # it groups the children fragment by classname and extracts the list of ids
  # to create the json structure needed to update the "data" field
  # this method should be called when creating or deleting a child fragment
  def update_parent_references
    return if classname.nil? || parent.nil?

    parent_schema = parent.madmp_schema
    parent_data = parent.data
    classified_children = parent.children.group_by {
      |t| t.additional_info["property_name"] unless t.additional_info.nil?
    }

    parent_schema.schema["properties"].each do |key, prop|
      unless classified_children[key].nil?
        if prop["type"].eql?("array") && prop["items"]["type"].eql?("object")
          parent_data[key] = classified_children[key].map { |c| { "dbid" => c.id } }
        elsif prop["type"].eql?("object") && prop["schema_id"].present?
          parent_data[key] = { "dbid" => classified_children[key][0].id }
        end
      end
    end
    parent.update!(data: parent_data)
  end

  # This method return the fragment full record
  # It integrates its children into the JSON
  def get_full_fragment
    children = self.children
    editable_data = data
    editable_data.each do |prop, value|
      case value
      when Hash
        if value["dbid"].present?
          child_data = children.exists?(value["dbid"]) ? children.find(value["dbid"]) : MadmpFragment.find(value["dbid"])
          editable_data = editable_data.merge(
            {
              prop => child_data.get_full_fragment
            }
          )
        end
      when Array
        unless value.length.zero?
          fragment_tab = []
          value.each do |v|
            next if v.nil?

            if v.instance_of?(Hash) && v["dbid"].present?
              child_data = children.exists?(v["dbid"]) ? children.find(v["dbid"]) : MadmpFragment.find(v["dbid"])
              fragment_tab.push(child_data.get_full_fragment)
            else
              fragment_tab.push(v)
            end
          end
          editable_data = editable_data.merge(
            {
              prop => fragment_tab
            }
          )
        end
      end
    end
    editable_data
  end

  # Validate the fragment data with the linked schema
  # and saves the result with the fragment data
  def self.validate_data(data, schema)
    schemer = JSONSchemer.schema(schema)
    unformated = schemer.validate(data).to_a
    validations = {}
    unformated.each do |valid|
      next if valid["type"] == "object"

      key = valid["data_pointer"][1..-1]
      if valid["type"] == "required"
        required = JsonPath.on(valid, "$..missing_keys").flatten
        required.each do |req|
          validations[req] ? validations[req].push("required") : validations[req] = ["required"]
        end
      else
        validations[key] ? validations[key].push(valid["type"]) : validations[key] = [valid["type"]]
      end
    end
    validations
  end

  # This method is called when a form is opened for the first time
  # It creates the whole tree of sub_fragments
  def instantiate
    save! unless id.present?

    new_data = data
    madmp_schema.schema["properties"].each do |key, prop|
      next if prop["type"] != "object" && prop["schema_id"].nil?

      sub_schema = MadmpSchema.find(prop["schema_id"])
      sub_fragment = MadmpFragment.new(
        data: {},
        answer_id: nil,
        dmp_id: dmp.id,
        parent_id: id,
        madmp_schema: sub_schema,
        additional_info: { property_name: key }
      )
      sub_fragment.assign_attributes(classname: sub_schema.classname)
      sub_fragment.instantiate
      new_data[key] = { "dbid" => sub_fragment.id }
    end
    update!(data: new_data)
  end

  def save_as_multifrag(param_data, schema)
    fragmented_data = {}
    p "####"
    p schema
    p "####"
    param_data.each do |prop, content|
      schema_prop = schema.schema["properties"][prop]
      p "####"
      p prop
      p "####"
      if schema_prop["type"].present? && schema_prop["type"].eql?("object")
        sub_data = content # TMP: for readability
        sub_schema = MadmpSchema.find(schema_prop["schema_id"])

        if param_data.present? && param_data[prop].present? && data[prop]["dbid"]
          sub_fragment = MadmpFragment.find(data[prop]["dbid"])
          sub_fragment.save_as_multifrag(sub_data, sub_schema)
        end
      else
        fragmented_data[prop] = content
      end
    end
    update!(data: data.merge(fragmented_data))
  end

  def self.find_sti_class(type_name)
    self
  end

  private

  # Initialize the data field
  def set_defaults
    self.data ||= {}
  end

end
