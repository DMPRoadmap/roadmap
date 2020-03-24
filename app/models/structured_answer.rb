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
#
# Indexes
#
#  index_structured_answers_on_answer_id                  (answer_id)
#  index_structured_answers_on_structured_data_schema_id  (structured_data_schema_id)
#

class StructuredAnswer < ActiveRecord::Base
  belongs_to :answer
  belongs_to :structured_data_schema

  self.inheritance_column = :classname 


  scope :backup_policies, -> { where(classname: 'Fragment::BackupPolicy') } 
  scope :costs, -> { where(classname: 'Fragment::Cost') } 
  scope :distributions, -> { where(classname: 'Fragment::Distribution') } 
  scope :dmps, -> { where(classname: 'Fragment::Dmp') } 
  scope :documentations, -> { where(classname: 'Fragment::Documentation') } 
  scope :ethical_issues, -> { where(classname: 'Fragment::EthicalIssue') } 
  scope :funders, -> { where(classname: 'Fragment::Funder') } 
  scope :metas, -> { where(classname: 'Fragment::Meta') } 
  scope :metadata_formats, -> { where(classname: 'Fragment::MetadataFormat') } 
  scope :methodology_issues, -> { where(classname: 'Fragment::MethodologyIssue') } 
  scope :partners, -> { where(classname: 'Fragment::Partner') } 
  scope :persons, -> { where(classname: 'Fragment::Person') }
  scope :personal_datas, -> { where(classname: 'Fragment::PersonalData') }
  scope :preservation_issues, -> { where(classname: 'Fragment::PreservationIssue') }
  scope :projects, -> { where(classname: 'Fragment::Project') } 
  scope :research_outputs, -> { where(classname: 'Fragment::ResearchOutput') } 
  scope :reuse_datas, -> { where(classname: 'Fragment::ReuseData') } 
  scope :sharings, -> { where(classname: 'Fragment::Sharing') } 
  scope :staff_members, -> { where(classname: 'Fragment::StaffMember') } 
  scope :technical_resource_usages, -> { where(classname: 'Fragment::TechnicalResourceUsage') } 
  scope :technical_resources, -> { where(classname: 'Fragment::TechnicalResource') } 
end
