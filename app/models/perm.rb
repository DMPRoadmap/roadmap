# == Schema Information
#
# Table name: perms
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Perm < ActiveRecord::Base
  include ValidationMessages

  NAME_AND_TEXT = {
    add_organisations: _('Add organisations'),
    change_org_affiliation: _('Change affiliation'),
    grant_permissions: _('Manage user privileges'),
    modify_templates: _('Manage templates'),
    modify_guidance: _('Manage guidance'),
    use_api: _('API rights'),
    change_org_details: _('Manage organisation details'),
    grant_api_to_orgs: _('Grant API to organisations')
  }

  # ================
  # = Associations =
  # ================

  has_and_belongs_to_many :users, join_table: :users_perms

  # ===============
  # = Validations =
  # ===============

  validates :name, presence: { message: PRESENCE_MESSAGE },
                   uniqueness: { message: UNIQUENESS_MESSAGE }


  # =================
  # = Class methods =
  # =================

  def self.add_orgs
    Perm.find_by(name: 'add_organisations')
  end

  def self.change_affiliation
    Perm.find_by(name: 'change_org_affiliation')
  end

  def self.grant_permissions
    Perm.find_by(name: 'grant_permissions')
  end

  def self.modify_templates
    Perm.find_by(name: 'modify_templates')
  end

  def self.modify_guidance
    Perm.find_by(name: 'modify_guidance')
  end

  def self.use_api
    Perm.find_by(name: 'use_api')
  end

  def self.change_org_details
    Perm.find_by(name: 'change_org_details')
  end

  def self.grant_api
    Perm.find_by(name: 'grant_api_to_orgs')
  end
end
