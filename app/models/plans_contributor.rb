# frozen_string_literal: true

# == Schema Information
#
# Table name: plans_contributors
#
#  id                   :integer          not null, primary key
#  plan_id              :integer
#  contributor_id       :integer
#  roles                :integer
#  created_at           :datetime
#  updated_at           :datetime
#
# Indexes
#
#  index_plans_contributors_on_roles (role)
#
# Foreign Keys
#
#  fk_rails_...  (plan_id => plans.id)
#  fk_rails_...  (contributor_id => contributors.id)
#

class PlansContributor < ActiveRecord::Base

  include FlagShihTzu
  include ValidationMessages

  # ================
  # = Associations =
  # ================

  belongs_to :plan

  belongs_to :contributor

  # =====================
  # = Nested Attributes =
  # =====================

  accepts_nested_attributes_for :contributor

  # ===============
  # = Validations =
  # ===============

  validates :roles, presence: { message: PRESENCE_MESSAGE }

  CREDIT_TAXONOMY_URI_BASE = "https://dictionary.casrai.org/Contributor_Roles".freeze

  ##
  # Define Bit Field values for roles
  # Derived from the CASRAI CRediT Taxonomy: https://casrai.org/credit/
  has_flags 1 =>  :conceptualization,
            2 =>  :data_curation,
            3 =>  :formal_analysis,
            4 =>  :funding_acquisition,
            5 =>  :investigation,
            6 =>  :methodology,
            7 =>  :project_administration,
            8 =>  :resources,
            9 =>  :software,
            10 => :supervision,
            11 => :validation,
            12 => :visualization,
            13 => :writing_original_draft,
            14 => :writing_review_editing,
            column: "roles"
end
