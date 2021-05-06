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
  include CodebaseFragment

  # ================
  # = Associations =
  # ================

  belongs_to :answer
  belongs_to :madmp_schema, class_name: "MadmpSchema"
  belongs_to :dmp, class_name: "Fragment::Dmp", foreign_key: "dmp_id"
  has_many :children, class_name: "MadmpFragment", foreign_key: "parent_id", dependent: :destroy
  belongs_to :parent, class_name: "MadmpFragment", foreign_key: "parent_id"

  # ===============
  # = Validations =
  # ===============

  # validates :madmp_schema, presence: { message: PRESENCE_MESSAGE }

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

  # ========================
  # = Public class methods =
  # ========================

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
    return additional_info["custom_value"] if additional_info["custom_value"].present?

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
  def update_children_references
    updated_data = data
    classified_children = children.group_by {
      |t| t.additional_info["property_name"] unless t.additional_info.nil?
    }

    madmp_schema.schema["properties"].each do |key, prop|
      if prop["type"].eql?("array") && prop["items"]["type"].eql?("object")
        updated_data[key] = []
        if classified_children[key].present?
          updated_data[key] = classified_children[key].map { |c| { "dbid" => c.id } }
          next
        end
      elsif prop["type"].eql?("object") && prop["schema_id"].present?
        next if classified_children[key].nil?

        updated_data[key] = { "dbid" => classified_children[key][0].id }
      end
    end
    update!(data: updated_data)
  end

  def update_parent_references
    return if classname.nil? || parent.nil?

    parent.update_children_references
  end

  # This method return the fragment full record
  # It integrates its children into the JSON
  def get_full_fragment(with_ids = false)
    return { "custom_value" => additional_info["custom_value"] } if additional_info["custom_value"].present?

    children = self.children
    editable_data = data
    editable_data.each do |prop, value|
      if value.is_a?(Hash) && value["dbid"].present?
        child = children.exists?(value["dbid"]) ? children.find(value["dbid"]) : MadmpFragment.find(value["dbid"])
        child_data = nil
        if child.additional_info["custom_value"].present?
          child_data = { "custom_value" => child.additional_info["custom_value"] }
        else
          child_data = child.get_full_fragment(with_ids)
        end
        editable_data = editable_data.merge(prop => child_data)
      end

      if value.is_a?(Array) && !value.empty?
        fragment_tab = []
        value.each do |v|
          next if v.nil?

          if v.is_a?(Hash) && v["dbid"].present?
            child_data = children.exists?(v["dbid"]) ? children.find(v["dbid"]) : MadmpFragment.find(v["dbid"])
            fragment_tab.push(child_data.get_full_fragment(with_ids))
          else
            fragment_tab.push(v)
          end
        end
        editable_data = editable_data.merge(prop => fragment_tab)
      end
    end
    if with_ids
      editable_data = { "id" => id, "schema_id" => madmp_schema_id }.merge(editable_data)
    end
    editable_data
  end

  # This method take a fragment and convert its data with the target schema
  def schema_conversion(target_schema)
    origin_schema_properties = madmp_schema.schema["properties"]
    converted_data = {}

    target_schema.schema["properties"].each do |key, target_prop|
      origin_prop = origin_schema_properties[key]
      next if origin_prop.nil?

      if target_prop["type"].eql?("array")
        converted_data[key] = data[key].is_a?(Array) ? data[key] : [data[key]]
        if target_prop["items"]["type"].eql?("object")
          next if converted_data[key].empty? || converted_data[key].first.nil?

          target_sub_schema = MadmpSchema.find(target_prop["items"]["schema_id"])
          converted_data[key].map { |v| MadmpFragment.find(v["dbid"]).schema_conversion(target_sub_schema) }
        end
      elsif origin_prop["type"].eql?("object")
        next if origin_prop["inputType"].present? && origin_prop["inputType"].eql?("pickOrCreate")

        sub_fragment = MadmpFragment.find(data[key]["dbid"])
        target_sub_schema = MadmpSchema.find(target_prop["schema_id"])
        sub_fragment.schema_conversion(target_sub_schema)
        converted_data[key] = data[key]
      elsif origin_prop["type"].eql?("array")
        if target_prop["type"].eql?("object")
          target_sub_schema = MadmpSchema.find(target_prop["schema_id"])
          data[key] = [] if data[key].nil?
          if data[key].empty?
            sub_fragment = MadmpFragment.new(
              data: {},
              answer_id: nil,
              dmp_id: dmp.id,
              parent_id: id,
              madmp_schema: target_sub_schema,
              additional_info: { property_name: key }
            )
            sub_fragment.assign_attributes(classname: sub_fragment.classname)
            sub_fragment.instantiate
          else
            first_id = data[key].first["dbid"]
            MadmpFragment.find(first_id).schema_conversion(target_sub_schema)
            converted_data[key] = { "dbid" => first_id }
          end
        else
          converted_data[key] = data[key].first
        end
      else
        converted_data[key] = data[key]
      end
    end
    update!(
      data: converted_data,
      madmp_schema_id: target_schema.id
    )
    update_children_references
  end

  # This method is called when a form is opened for the first time
  # It creates the whole tree of sub_fragments
  def instantiate
    save! unless id.present?

    new_data = data
    madmp_schema.schema["properties"].each do |key, prop|
      if prop["type"].eql?("object") && prop["schema_id"].present?
        sub_schema = MadmpSchema.find(prop["schema_id"])

        next if sub_schema.classname.eql?("person") || new_data[key].present?

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
    end
    update!(data: new_data)
  end

  def save_as_multifrag(param_data, schema)
    fragmented_data = {}
    param_data.each do |prop, content|
      schema_prop = schema.schema["properties"][prop]

      next if schema_prop&.dig("type").nil?

      if schema_prop["type"].eql?("object") &&
         schema_prop["schema_id"].present?
        sub_data = content # TMP: for readability
        sub_schema = MadmpSchema.find(schema_prop["schema_id"])
        instantiate unless data[prop].present?
        next if param_data.nil?

        if schema_prop&.dig("inputType").eql?("pickOrCreate")
          fragmented_data[prop] = content
        elsif schema_prop["overridable"].present? &&
              param_data.dig(prop, "custom_value").present?
          # if the property is overridable & value is custom, take the value as is
          sub_fragment = MadmpFragment.find(data[prop]["dbid"])
          additional_info = sub_fragment.additional_info.merge(sub_data)
          sub_fragment.update(
            data: {},
            additional_info: additional_info
          )
        elsif data.dig(prop, "dbid")
          sub_fragment = MadmpFragment.find(data[prop]["dbid"])
          sub_fragment.save_as_multifrag(sub_data, sub_schema)
        end
      else
        fragmented_data[prop] = content
      end
    end
    update!(
      data: data.merge(fragmented_data),
      additional_info: additional_info.except!("custom_value")
    )
  end

  def get_property(property_name)
    return if data.empty? || data[property_name].nil?

    if data[property_name]["dbid"].present?
      MadmpFragment.find(data[property_name]["dbid"])
    else
      data[property_name]
    end
  end

  # =================
  # = Class methods =
  # =================

  # Validate the fragment data with the linked schema
  # and saves the result with the fragment data
  def self.validate_data(data, schema)
    schemer = JSONSchemer.schema(schema)
    unformated = schemer.validate(data).to_a
    validations = {}
    unformated.each do |valid|
      next if valid["type"].eql?("object")

      key = valid["data_pointer"][1..-1]
      if valid["type"].eql?("required")
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

  # Checks for a given dmp_id (and parent_id) if a fragment exists in the database
  def self.fragment_exists?(data, schema, dmp_id, parent_id = nil)
    return false if schema.schema["unicity"].nil? || schema.schema["unicity"].empty?

    classname = schema.classname
    parent_id = nil if classname.eql?("person")
    unicity_properties = schema.schema["unicity"]
    dmp_fragments = MadmpFragment.where(
      dmp_id: dmp_id,
      parent_id: parent_id,
      classname: classname
    )
    dmp_fragments.each do |fragment|
      filtered_db_data = fragment.data.slice(*unicity_properties)
      filtered_incoming_data = data.slice(*unicity_properties)
      next if filtered_db_data.empty?

      return true if filtered_db_data.eql?(filtered_incoming_data)
    end
    false
  end

  def self.find_sti_class(type_name)
    self
  end

  private

  # Initialize the data field
  def set_defaults
    self.data ||= {}
    self.additional_info ||= {}
    self.parent_id = nil if classname.eql?("person")
  end

end
