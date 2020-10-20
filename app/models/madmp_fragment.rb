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
require 'jsonpath'

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
  scope :budgets, -> { where(classname: 'budgets') } 
  scope :costs, -> { where(classname: 'cost') } 
  scope :data_collections, -> { where(classname: 'data_collection') } 
  scope :data_processings, -> { where(classname: 'data_processing') } 
  scope :data_storages, -> { where(classname: 'data_storage') } 
  scope :distributions, -> { where(classname: 'distribution') } 
  scope :dmps, -> { where(classname: 'dmp') } 
  scope :documentation_qualities, -> { where(classname: 'documentation_quality') } 
  scope :ethical_issues, -> { where(classname: 'ethical_issue') } 
  scope :funders, -> { where(classname: 'funder') } 
  scope :fundings, -> { where(classname: 'funding') } 
  scope :metas, -> { where(classname: 'meta') } 
  scope :metadata_standards, -> { where(classname: 'metadata_standard') } 
  scope :partners, -> { where(classname: 'partner') } 
  scope :persons, -> { where(classname: 'person') }
  scope :personal_data_issues, -> { where(classname: 'personal_data_issue') }
  scope :preservation_issues, -> { where(classname: 'preservation_issue') }
  scope :projects, -> { where(classname: 'project') } 
  scope :research_outputs, -> { where(classname: 'research_output') } 
  scope :research_output_descriptions, -> { where(classname: 'research_output_description') } 
  scope :reuse_datas, -> { where(classname: 'reuse_data') } 
  scope :sharings, -> { where(classname: 'sharing') } 
  scope :technical_resource_usages, -> { where(classname: 'technical_resource_usage') } 
  scope :technical_resources, -> { where(classname: 'technical_resource') } 


  # =============
  # = Callbacks =
  # =============

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
    if self.dmp.nil?
      Plan.find(data["plan_id"])
    else
      self.dmp.plan
    end
  end

  # Returns the schema associated to the JSON fragment
  def json_schema
    self.madmp_schema.schema
  end

  def get_dmp_fragments
    MadmpFragment.where(dmp_id: dmp_id)
  end

  # Returns a human readable version of the structured answer
  def to_s 
  # displayable = ""
  # if json_schema["to_string"]
  #   json_schema["to_string"].each do |pattern|
  #     # if it's a JsonPath pattern
  #     if pattern.first == "$"
  #       displayable += JsonPath.on(self.data, pattern).first
  #     else 
  #       displayable += pattern
  #     end
  #   end
  # else 
  #   displayable = self.data.to_s
  # end
  # displayable
    self.data.to_s
  end

  # This method generates references to the child fragments in the parent fragment
  # it updates the json "data" field in the database
  # it groups the children fragment by classname and extracts the list of ids
  # to create the json structure needed to update the "data" field
  # this method should be called when creating or deleting a child fragment
  def update_parent_references
    return if classname.nil?
    unless self.parent.nil?
      # Get each fragment grouped by its classname
      classified_children = parent.children.group_by(&:classname)
      parent_data = self.parent.data

      classified_children.each do |classname, children|
        if children.count >= 2
          # if there is more than 1 child, should pluralize the classname
          parent_data = parent_data.merge( { 
            classname.pluralize(2) => children.map { |c| { "dbid" => c.id } }
          } )
          parent_data.delete(classname) if parent_data[classname] && classname != "meta"
        else 
          parent_data = parent_data.merge( { 
            classname => { "dbid" => children.first.id }
          } )
          parent_data.delete(classname.pluralize(2)) if parent_data[classname.pluralize(2)] && classname != "meta"
        end 
      end
      self.parent.update(data: parent_data)
    end
  end

  # This method return the fragment full record
  # It integrates its children into the JSON 
  def get_full_fragment
    children = self.children
    editable_data = self.data
    editable_data.each do |prop, value|
      case value
      when Hash
        if value["dbid"].present?
          child_data = children.exists?(value["dbid"]) ? children.find(value["dbid"]) : MadmpFragment.find(value["dbid"])
          editable_data = editable_data.merge(
            { 
              prop => child_data.get_full_fragment()
            }
          )
        end
      when Array
        unless value.length == 0
          fragment_tab = Array.new
          value.each do |v|
            next if v.nil?

            if v.instance_of?(Hash) && v["dbid"].present?
              child_data = children.exists?(v["dbid"]) ? children.find(v["dbid"]) : MadmpFragment.find(v["dbid"])
              fragment_tab.push(child_data.get_full_fragment())
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

  # Saves (and creates, if needed) the structured answer ("fragment")
  def self.save_madmp_fragment(answer, data, schema, parent_id = nil)
    # Extract the form data corresponding to the schema of the structured question
    s_answer = MadmpFragment.find_or_initialize_by(answer_id: answer.id) do |sa|
      sa.answer = answer
      sa.madmp_schema = schema
      sa.classname = schema.classname
      sa.dmp_id = answer.plan.json_fragment().id
      sa.parent_id = parent_id
    end
    additional_info = { 
      "validations" => self.validate_data(data, schema.schema)
    }
    s_answer.assign_attributes(data: data, additional_info: additional_info)
    s_answer.save
  end


  # Validate the fragment data with the linked schema 
  # and saves the result with the fragment data
  def self.validate_data(data, schema)
    schemer = JSONSchemer.schema(schema)
    unformated = schemer.validate(data).to_a
    validations = {}
    unformated.each do |valid| 
      unless valid['type'] == "object"
        key = valid['data_pointer'][1..-1]
        if valid['type'] == "required"
          required = JsonPath.on(valid, '$..missing_keys').flatten
          required.each do |req| 
            validations[req] ? validations[req].push("required") : validations[req] = ["required"]
          end
        else 
          validations[key] ? validations[key].push(valid['type']) : validations[key] = [valid['type']]
        end 
      end
    end
    validations
  end

  def save_as_multifrag(previous_data)
    # save!
    schema_properties = json_schema['properties']
    data.each do |prop, content|
      schema_prop = schema_properties[prop]
      if !schema_prop.nil? && schema_prop['type'].eql?('object')
        sub_schema = MadmpSchema.find(schema_prop['schema_id'])
        sub_fragment_id = previous_data[prop]['dbid'] if previous_data
        if sub_fragment_id.nil?
          sub_fragment = MadmpFragment.new
        else
          sub_fragment = MadmpFragment.find(sub_fragment_id)
        end
        # sub_fragment = MadmpFragment.new(
        sub_fragment.assign_attributes(
          data: content,
          dmp_id: dmp_id,
          parent_id: id,
          madmp_schema_id: sub_schema.id
        )
        sub_fragment.classname = sub_schema.classname
        sub_fragment.save_as_multifrag(nil) #TODO: pass the real value
        data[prop] = { "dbid": sub_fragment_id }
      end
    end
    save
  end

  def self.find_sti_class(type_name)
    self
  end
end
