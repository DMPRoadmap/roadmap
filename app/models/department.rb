# frozen_string_literal: true

# == Schema Information
#
# Table name: departments
#
#  id         :integer          not null, primary key
#  code       :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  org_id     :integer
#
# Indexes
#
#  index_departments_on_org_id  (org_id)
#

# Object that a department within an Org
class Department < ApplicationRecord
  belongs_to :org

  has_many :users, dependent: :nullify

  # ===============
  # = Validations =
  # ===============

  validates :org, presence: { message: PRESENCE_MESSAGE }

  validates :name, presence: { message: PRESENCE_MESSAGE },
                   uniqueness: { message: UNIQUENESS_MESSAGE,
                                 scope: :org_id, case_sensitive: false }

  validates :name, uniqueness: { message: UNIQUENESS_MESSAGE,
                                 scope: :org_id }

  # Retrieves every department associated to an org
  scope :by_org, ->(org) { where(org_id: org.id) }
end
