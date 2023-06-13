# frozen_string_literal: true

require 'securerandom'

# == Schema Information
#
# Table name: themes
#
#  id          :integer          not null, primary key
#  identifier  :string           not null
#  user_id     :integer
#  metadata    :json
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

# Object that represents a question/guidance theme
class Wip < ApplicationRecord
  INVALID_JSON_MSG = "must contain a top level :dmp and at least a :title. For example: `{ dmp: { title: 'Test' } }`"

  belongs_to :user

  before_validation :generate_identifier
  after_validation :remove_wip_id_from_metadata

  validates :user, presence: { message: PRESENCE_MESSAGE }
  validate :validate_metadata

  # Attach the wip_id to the metadata
  def to_json
    data = metadata
    data['dmp']['wip_id'] = { type: 'other', identifier: identifier } if data['dmp'].present? && identifier.present?
    JSON.parse(data.to_json).to_json
  end

  protected

  # Auto assign a unique identifier for new records
  def generate_identifier
    if new_record?
      self.identifier = "#{Time.now.strftime('%Y%m%d')}-#{SecureRandom.hex(6)}"
    end
  end

  # Strip out the wip_id if it was included
  def remove_wip_id_from_metadata
    metadata[:dmp].delete(:wip_id) if metadata.is_a?(Hash) && metadata[:dmp].present? && metadata[:dmp][:wip_id].present?
  end

  private

  # Ensure that the metadata JSON is valid
  def validate_metadata
    unless metadata.present? && metadata.is_a?(Hash) &&
           metadata.with_indifferent_access.fetch(:dmp, {})[:title].present?
      errors.add(:metadata, INVALID_JSON_MSG)
    end
  end
end
