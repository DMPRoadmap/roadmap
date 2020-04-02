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
  belongs_to :answer
  belongs_to :structured_data_schema
  belongs_to :dmp, class_name: "Fragment::Dmp", foreign_key: "dmp_id"
  has_many :children, class_name: "StructuredAnswer", foreign_key: "parent_id"

  self.inheritance_column = :classname 


  scope :backup_policies, -> { where(classname: 'backup_policy') } 
  scope :costs, -> { where(classname: 'cost') } 
  scope :distributions, -> { where(classname: 'distribution') } 
  scope :dmps, -> { where(classname: 'dmp') } 
  scope :documentations, -> { where(classname: 'documentation') } 
  scope :ethical_issues, -> { where(classname: 'ethicalIssue') } 
  scope :funders, -> { where(classname: 'funder') } 
  scope :metas, -> { where(classname: 'meta') } 
  scope :metadata_formats, -> { where(classname: 'metadata_format') } 
  scope :methodology_issues, -> { where(classname: 'methodology_issue') } 
  scope :partners, -> { where(classname: 'partner') } 
  scope :persons, -> { where(classname: 'person') }
  scope :personal_datas, -> { where(classname: 'personal_data') }
  scope :preservation_issues, -> { where(classname: 'preservation_issue') }
  scope :projects, -> { where(classname: 'project') } 
  scope :research_outputs, -> { where(classname: 'research_output') } 
  scope :reuse_datas, -> { where(classname: 'reuse_data') } 
  scope :sharings, -> { where(classname: 'sharing') } 
  scope :staff_members, -> { where(classname: 'staff_member') } 
  scope :technical_resource_usages, -> { where(classname: 'technical_resource_usage') } 
  scope :technical_resources, -> { where(classname: 'technical_resource') } 


  def self.find_sti_class(type_name)
    self
  end
end
