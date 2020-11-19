# frozen_string_literal: true

# == Schema Information
#
# Table name: perms
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Perm < ApplicationRecord

  # =============
  # = Constants =
  # =============

  ADD_ORGS            = Perm.where( name: "add_organisations" ).first.freeze
  CHANGE_AFFILIATION  = Perm.where( name: "change_org_affiliation" ).first.freeze
  GRANT_PERMISSIONS   = Perm.where( name: "grant_permissions" ).first.freeze
  MODIFY_TEMPLATES    = Perm.where( name: "modify_templates" ).first.freeze
  MODIFY_GUIDANCE     = Perm.where( name: "modify_guidance" ).first.freeze
  USE_API             = Perm.where( name: "use_api" ).first.freeze
  CHANGE_ORG_DETAILS  = Perm.where( name: "change_org_details" ).first.freeze
  GRANT_API           = Perm.where( name: "grant_api_to_orgs" ).first.freeze
  REVIEW_PLANS        = Perm.where( name: "review_org_plans" ).first.freeze

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
    ADD_ORGS
  end

  def self.change_affiliation
    CHANGE_AFFILIATION
  end

  def self.grant_permissions
    GRANT_PERMISSIONS
  end

  def self.modify_templates
    MODIFY_TEMPLATES
  end

  def self.modify_guidance
    MODIFY_GUIDANCE
  end

  def self.use_api
    USE_API
  end

  def self.change_org_details
    CHANGE_ORG_DETAILS
  end

  def self.grant_api
    GRANT_API
  end

  def self.review_plans
    REVIEW_PLANS
  end

end
