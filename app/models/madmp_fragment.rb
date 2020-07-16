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
  scope :costs, -> { where(classname: 'cost') } 
  scope :data_collections, -> { where(classname: 'data_collection') } 
  scope :data_qualities, -> { where(classname: 'data_quality') } 
  scope :distributions, -> { where(classname: 'distribution') } 
  scope :dmps, -> { where(classname: 'dmp') } 
  scope :documentations, -> { where(classname: 'documentation') } 
  scope :ethical_issues, -> { where(classname: 'ethical_issue') } 
  scope :funders, -> { where(classname: 'funder') } 
  scope :fundings, -> { where(classname: 'funding') } 
  scope :metas, -> { where(classname: 'meta') } 
  scope :metadata_formats, -> { where(classname: 'metadata_format') } 
  scope :partners, -> { where(classname: 'partner') } 
  scope :persons, -> { where(classname: 'person') }
  scope :personal_data_issues, -> { where(classname: 'personal_data_issue') }
  scope :preservation_issues, -> { where(classname: 'preservation_issue') }
  scope :projects, -> { where(classname: 'project') } 
  scope :research_outputs, -> { where(classname: 'research_output') } 
  scope :reuse_datas, -> { where(classname: 'reuse_data') } 
  scope :sharings, -> { where(classname: 'sharing') } 
  scope :staff_members, -> { where(classname: 'staff_member') } 
  scope :technical_resource_usages, -> { where(classname: 'technical_resource_usage') } 
  scope :technical_resources, -> { where(classname: 'technical_resource') } 


  # =============
  # = Callbacks =
  # =============

  after_create  :update_parent_references
  after_destroy :update_parent_references

  # =================
  # = Class methods =
  # =================

  def plan
    plan = nil
    if self.answer.nil?
      self.dmp.plan
    else
      plan = self.answer.plan
    end
  end

  # Returns the schema associated to the JSON fragment
  def json_schema
    self.madmp_schema.schema
  end

  def get_sub_fragments
    sub_fragments = self.dmp.persons.group_by(&:madmp_schema_id)
    unless self.children.empty?
      sub_fragments.merge(self.children.group_by(&:madmp_schema_id))
    end

    sub_fragments
  end

  # Returns a human readable version of the structured answer
  def to_s 
    displayable = ""
    if json_schema["to_string"]
      json_schema["to_string"].each do |pattern|
        # if it's a JsonPath pattern
        if pattern.first == "$"
          displayable += JsonPath.on(self.data, pattern).first
        else 
          displayable += pattern
        end
      end
    else 
      displayable = self.data.to_s
    end
    displayable
  end

  # This method generates references to the child fragments in the parent fragment
  # it updates the json "data" field in the database
  # it groups the children fragment by classname and extracts the list of ids
  # to create the json structure needed to update the "data" field
  # this method should be called when creating or deleting a child fragment
  def update_parent_references
    unless self.parent.nil?
      # Get each fragment grouped by its classname
      classified_children = parent.children.group_by(&:classname)
      parent_data = self.parent.data

      classified_children.each do |classname, children|
        if children.count >= 2
          # if there is more than 1 child, should pluralize the classname
          parent_data[classname.pluralize(children.count)] = children.map { |c| { "dbId" => c.id } }
          parent_data.delete(classname) if parent_data[classname]
        else 
          parent_data[classname] =  { "dbId" => children.first.id }
          parent_data.delete(classname.pluralize(2)) if parent_data[classname.pluralize(2)]
        end 
      end
      self.parent.update(data: parent_data)
    end
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
    data = data.merge({ 
      "validations" => self.validate_data(data, schema.schema)
    })
    s_answer.assign_attributes(data: data)
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

  def self.find_sti_class(type_name)
    self
  end
end
