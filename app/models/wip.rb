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
  INVALID_JSON_MSG = 'must contain a top level :dmp and at least a :title. For example: `{ dmp: { title: \'Test\' } }`'
  INVALID_NARRATIVE_FORMAT = 'must be a PDF document.'

  belongs_to :user

  # ActiveStorage for Narrative PDF document
  has_one_attached :narrative

  # Ensure that the :identifier has been generated on new records
  before_validation :generate_identifier

  # Ensure the :wip_id and :dmproadmap_related_identifier for the narrative are not in the :metadata
  # they are attached on the fly during the call to :to_json
  after_validation :remove_wip_id_and_narrative_from_metadata

  # Ensure that the narrative PDF is removed from ActiveStorage before deleting the WIP
  before_destroy :remove_narrative

  validates :user, presence: { message: PRESENCE_MESSAGE }
  validate :validate_metadata

  # Attach the wip_id and narrative to the metadata
  def to_json
    data = metadata
    data['dmp']['wip_id'] = { type: 'other', identifier: identifier } if data['dmp'].present? && identifier.present?
    return JSON.parse(data.to_json).to_json unless narrative.attached?

    data['dmp']['dmproadmap_related_identifiers'] = [] unless data['dmp']['dmproadmap_related_identifiers']
    data['dmp']['dmproadmap_related_identifiers'] << narrative_to_related_identifier
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
  def remove_wip_id_and_narrative_from_metadata
    if metadata.present? && metadata['dmp'].present?
      metadata['dmp'].delete('wip_id') if metadata.is_a?(Hash) && metadata['dmp'].present? && metadata['dmp']['wip_id'].present?
      metadata['dmp'].fetch('dmproadmap_related_identifiers', []).delete_if { |id| id['descriptor'] == 'is_metadata_for' }
    end
  end

  def remove_narrative
    # Let ActiveJob delete from ActiveStorage when it has bandwidth
    narrative.purge_later if narrative.attached?
  end

  private

  # Ensure that the metadata JSON is valid
  def validate_metadata
    unless metadata.present? && metadata.is_a?(Hash) &&
           metadata.with_indifferent_access.fetch(:dmp, {})[:title].present?
      errors.add(:metadata, INVALID_JSON_MSG)
    end
  end

  # Convert the narrative info into a retrieval URL
  def narrative_to_related_identifier
    return nil unless narrative.attached?

    JSON.parse({
      type: 'url',
      descriptor: 'is_metadata_for',
      work_type: 'output_management_plan',
      identifier: Rails.application.routes.url_helpers.rails_blob_url(narrative, disposition: 'attachment')
    }.to_json)
  end
end
