# frozen_string_literal: true

# == Schema Information
#
# Table name: api_logs
#
#  id                   :integer          not null, primary key
#  oauth_application_id :integer          not null
#  change_type          :integer          not null
#  activity             :text             not null
#  logable_id           :integer          not null
#  logable_type         :string           not null
#
# Indexes
#
#  index_api_logs_on_api_client_id (api_client_id)
#  index_api_logs_on_change_type (change_type)
#  index_api_logs_on_logable_and_change_type (logable_id, logable_type, change_type)
#
class ApiLog < ApplicationRecord
  enum change_type: %i[added removed modified]

  # ================
  # = Associations =
  # ================

  belongs_to :logable, polymorphic: true

  belongs_to :api_client

  # ===============
  # = Validations =
  # ===============

  validates :activity, presence: { message: PRESENCE_MESSAGE }

  validates :change_type, presence: { message: PRESENCE_MESSAGE }

  validates :logable, presence: { message: PRESENCE_MESSAGE }

  validates :api_client, presence: { message: PRESENCE_MESSAGE }
end
