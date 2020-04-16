# == Schema Information
#
# Table name: structured_answers
#
#  id                        :integer          not null, primary key
#  data                      :json
#  answer_id                 :integer
#  structured_data_schema_id :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  classname                 :string
#  dmp_id                    :integer
#  parent_id                 :integer
#
# Indexes
#
#  index_structured_answers_on_answer_id                  (answer_id)
#  index_structured_answers_on_structured_data_schema_id  (structured_data_schema_id)
#

class StructuredAnswer < ActiveRecord::Base
  
  include ValidationMessages

  # ================
  # = Associations =
  # ================

  belongs_to :answer
  belongs_to :structured_data_schema
  belongs_to :dmp, class_name: "Fragment::Dmp", foreign_key: "dmp_id"
  has_many :children, class_name: "StructuredAnswer", foreign_key: "parent_id"
  belongs_to :parent, class_name: "StructuredAnswer", foreign_key: "parent_id" 

  # ===============
  # = Validations =
  # ===============

  #validates :structured_data_schema, presence: { message: PRESENCE_MESSAGE }

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
  scope :ethical_issues, -> { where(classname: 'ethicalIssue') } 
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
        else 
          parent_data[classname] =  { "dbId" => children.first.id }
        end 
      end
      self.parent.update(data: parent_data)
    end
  end

  def self.find_sti_class(type_name)
    self
  end
end
