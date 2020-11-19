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

  #load all records as frozen objects and assign constants
  Perm.all.each { |perm| const_set( perm.name.upcase, perm.freeze ) }

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
    ADD_ORGANISATIONS
  end

  def self.change_affiliation
    CHANGE_ORG_AFFILIATION
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
    GRANT_API_TO_ORGS
  end

  def self.review_plans
    REVIEW_ORG_PLANS
  end

end
