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

  # ================
  # = Associations =
  # ================

  has_and_belongs_to_many :users, join_table: :users_perms

  # ===============
  # = Validations =
  # ===============

  validates :name, presence: { message: PRESENCE_MESSAGE },
                   uniqueness: { message: UNIQUENESS_MESSAGE }

  # ==========
  # = Scopes =
  # ==========

  scope :add_orgs, -> { Perm.find_by(name: 'add_organisations') }

  scope :change_affiliation, -> { Perm.find_by(name: 'change_org_affiliation') }

  scope :grant_permissions, -> { Perm.find_by(name: 'grant_permissions') }

  scope :modify_templates, -> { Perm.find_by(name: 'modify_templates') }

  scope :modify_guidance, -> { Perm.find_by(name: 'modify_guidance') }

  scope :use_api, -> { Perm.find_by(name: 'use_api') }

  scope :change_org_details, -> { Perm.find_by(name: 'change_org_details') }

  scope :grant_api, -> { Perm.find_by(name: 'grant_api_to_orgs') }
end
