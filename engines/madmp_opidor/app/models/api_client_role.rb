# frozen_string_literal: true

# == Schema Information
#
# Table name: api_client_roles
#
#  id                 :bigint(8)        not null, primary key
#  access             :integer          default(0), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  api_client_id      :bigint(8)        not null
#  plan_id            :bigint(8)        not null
#  research_output_id :bigint(8)
#
# Indexes
#
#  index_api_client_roles_on_api_client_id       (api_client_id)
#  index_api_client_roles_on_plan_id             (plan_id)
#  index_api_client_roles_on_research_output_id  (research_output_id)
#
# Object that represents an api_client_role
class ApiClientRole < ApplicationRecord
  include FlagShihTzu

  # ================
  # = Associations =
  # ================

  belongs_to :api_client

  belongs_to :plan

  belongs_to :research_output, required: false

  ##
  # Define Bit Field Values
  # Column access
  has_flags 1 => :creator,  # 1
            2 => :edit,     # 2
            3 => :read,     # 4
            column: 'access'

  # ===============
  # = Validations =
  # ===============

  validates :api_client, presence: { message: PRESENCE_MESSAGE }

  validates :plan, presence: { message: PRESENCE_MESSAGE }

  validates :access, presence: { message: PRESENCE_MESSAGE },
                     numericality: { greater_than: 0, only_integer: true,
                                     message: _("can't be less than zero") }
end
