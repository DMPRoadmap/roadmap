# frozen_string_literal: true

require 'securerandom'

# == Schema Information
#
# Table name: drafts
#
#  id          :integer          not null, primary key
#  draft_id    :string           not null
#  user_id     :integer
#  metadata    :json
#  dmp_id      :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

# Object that represents a question/guidance theme
class Draft < ApplicationRecord
  include Dmptool::Registerable

  INVALID_JSON_MSG = 'must contain a top level :dmp and at least a :title. For example: `{ dmp: { title: \'Test\' } }`'
  INVALID_NARRATIVE_FORMAT = 'must be a PDF document.'

  belongs_to :user

  # ActiveStorage for Narrative PDF document
  has_one_attached :narrative

  # Ensure that the :draft_id has been generated on new records, timestamps are added, and any ROR IDs are added
  before_validation :generate_draft_id
  before_validation :generate_timestamps
  before_validation :append_ror_ids

  # Ensure the :draft_id and :dmproadmap_related_identifier for the narrative are not in the :metadata
  # they are attached on the fly during the call to :to_json
  after_validation :remove_draft_id_and_narrative_from_metadata

  # Ensure that the narrative PDF is removed from ActiveStorage before deleting the draft
  before_destroy :remove_narrative

  validates :user, presence: { message: PRESENCE_MESSAGE }
  validate :validate_metadata

  # The DMP ID must be unique (although it can be nil or blank). A nil/blank DMP ID indicates that the draft has
  # not been registered (aka it is not complete)
  validates_uniqueness_of :dmp_id, allow_blank: true

  # Validate that the attachment is a PDF and that it is less than 250KB
  validates :narrative, size: { less_than: 250.kilobytes , message: 'PDF too large, must be less than 350KB' },
                        content_type: { in: ['application/pdf'], message: 'must be a PDF document' }

  # Support for filtering and search
  def self.search(user:, params: {})
    return [] unless user.is_a?(User)

    recs = where(user_id: user.id)

    title = params.fetch(:title, '').to_s.strip
    funder = params.fetch(:funder, '').to_s.strip
    grant = params.fetch(:grant_id, '').to_s.strip
    visibility = params.fetch(:visibility, '').to_s.strip
    dmp_id = params.fetch(:dmp_id, '').to_s.strip

    clause = []
    clause << "(LOWER(metadata->>'$.dmp.title') LIKE :title OR LOWER(metadata->>'$.dmp.description') LIKE :title)" unless title.blank?
    clause << "LOWER(metadata->>'$.dmp.project[*].funding[*].name') LIKE :funder" if funder.present?
    clause << "LOWER(metadata->>'$.dmp.project[*].funding[*].grant_id.identifier') LIKE :grant" if grant.present?
    clause << "(LOWER(metadata->>'$.dmp.dmproadmap_privacy') = :visibility OR metadata->>'$.dmp.draft_data.is_private' = :private)" if visibility.present?
    clause << "dmp_id LIKE :dmp_id" if dmp_id.present?
    return recs unless clause.any?

    recs = recs.where(clause.join(' AND '), title: "%#{title.downcase}%", funder: "%#{funder.downcase}%",
                                            grant: "%#{grant.downcase}%", dmp_id: "%#{dmp_id}",
                                            visibility: visibility.downcase, private: (visibility.downcase == 'private').to_s)
    recs
  end

  # Method required by the DMPTool::Registerable concern that checks to see if the Plan has all of the
  # content required to register a DMP ID
  def registerable?
    return true if dmp_id.present?
    return false if draft_id.nil? || user.nil?

    hash = metadata.is_a?(String) ? JSON.parse(metadata).fetch('dmp', {}) : metadata.fetch('dmp', {})
    !hash['title'].blank? &&
      hash.fetch('contact', {})['name'].present? &&
      hash.fetch('contact', {})['mbox'].present? &&
      hash.fetch('contact', {}).fetch('contact_id', {})['type'].present? &&
      hash.fetch('contact', {}).fetch('contact_id', {})['identifier'].present?
  end

  # Attach the draft_id and narrative to the metadata
  def to_json
    data = metadata
    return JSON.parse(data.to_json).to_json unless data['dmp'].present?

    data['dmp']['draft_data'] = {} unless data['dmp']['draft_data'].present?
    data['dmp']['draft_data']['narrative'] = narrative_to_draft_data if narrative.attached?

    data['dmp']['dmp_id'] = { type: 'doi', identifier: dmp_id } if registered?
    data['dmp']['draft_id'] = { type: 'other', identifier: draft_id } if !registered? && draft_id.present?
    return JSON.parse(data.to_json).to_json unless narrative.attached?

    data['dmp']['dmproadmap_related_identifiers'] = [] unless data['dmp']['dmproadmap_related_identifiers']
    data['dmp']['dmproadmap_related_identifiers'] << narrative_to_related_identifier
    JSON.parse(data.to_json).to_json
  end

  # Render the DMP to JSON designed for submission to the DMPHub
  def to_json_for_registration
    data = metadata.dup
    my_url = Rails.application.routes.url_helpers.api_v3_url(self)
    base_url = Rails.env.development? ? 'http://localhost:3000' : ENV['DMPROADMAP_HOST']

    # Remove any ephemeral data
    data['dmp'].delete('draft_data')

    # TODO: Update JS in react-client to stop setting the contact (just have it define contributors
    #       with one designated as `"contact": true`)
    data['dmp']['contact'] = designate_contact if data['dmp'].fetch('contact', []).is_a?(Array)

    # Remove the contact designation before submitting the JSON for DMP ID registration
    data['dmp'].fetch('contributor', []).each do |contributor|
      next unless contributor.present?

      contributor.delete('mbox') if contributor['mbox'].nil?
      contributor.delete('contact')
    end

    # Prep the DMP ID and privacy setting
    data['dmp']['dmp_id'] = { type: 'doi', identifier: dmp_id } if registered?
    data['dmp']['dmp_id'] = { type: 'url', identifier: my_url } unless registered?
    data['dmp']['dataset'] = [] unless data['dmp']['dataset'].present?
    data['dmp']['project'] = [] unless data['dmp']['project'].present?
    data['dmp']['dmproadmap_privacy'] = 'private' unless data['dmp']['dmproadmap_privacy'].present?

    data['dmp'] = ensure_defaults(dmp: data['dmp'])
    JSON.parse(data.to_json).to_json
  end

  protected

  # Auto assign a unique draft_id for new records
  def generate_draft_id
    if new_record?
      self.draft_id = "#{Time.now.strftime('%Y%m%d')}-#{SecureRandom.hex(6)}"
    end
  end

  # Add the created and modified timestamps to the JSON
  def generate_timestamps
    return false if metadata.nil? || metadata['dmp'].nil?

    if metadata['dmp']['created'].nil?
      metadata['dmp']['created'] = new_record? ? Time.now.utc.iso8601 : created_at.to_formatted_s(:iso8601)
    end
    if metadata['dmp']['modified'].nil?
      metadata['dmp']['modified'] = new_record? ? metadata['dmp']['created'] : updated_at.to_formatted_s(:iso8601)
    end
    true
  end

  # Add the ROR IDs for any dmproadmap_affiliation that does not have one
  def append_ror_ids
    unless new_record?
      data = metadata.fetch('dmp', {})

      data.fetch('contributor', []).each do |contrib|
        next if contrib['dmproadmap_affiliation'].nil? ||
                contrib.fetch('dmproadmap_affiliation', {})['affiliation_id'].present?

        ror = RegistryOrg.find_by(name: contrib.fetch('dmproadmap_affiliation', {})['name'])&.ror_id
        json = JSON.parse({ type: 'ror', identifier: ror }.to_json)
        contrib['dmproadmap_affiliation']['affiliation_id'] = json if ror.present?
      end

      project = data.fetch('project', []).first
      return data if project.nil? || project.fetch('funding', []).first.nil?

      funding = project['funding'].first

      ror = RegistryOrg.find_by(name: funding['name'])&.ror_id
      funding['funder_id'] = JSON.parse({ type: 'ror', identifier: ror }.to_json) if ror.present?
    end
  end

  # Strip out the :draft_id, :dmp_id and :narrative info if they were included
  def remove_draft_id_and_narrative_from_metadata
    if metadata.present? && metadata['dmp'].present?
      metadata['dmp'].delete('dmp_id') if metadata.is_a?(Hash) && metadata['dmp'].present? && metadata['dmp']['dmp_id'].present?
      metadata['dmp'].delete('draft_id') if metadata.is_a?(Hash) && metadata['dmp'].present? && metadata['dmp']['draft_id'].present?
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
      identifier: safe_narrative_url
    }.to_json)
  end

  # Creates the narrative information needed by the UI
  def narrative_to_draft_data
    return {} unless narrative.attached?


    JSON.parse({ file_name: narrative.blob.filename, url: safe_narrative_url }.to_json)
  end

  def safe_narrative_url
    url = Rails.application.routes.url_helpers.rails_blob_url(narrative, disposition: 'attachment')
    url = "#{Rails.configuration.x.dmproadmap.server_host}/#{url}" if url.start_with?('https://https/rails')
    url = "https://#{url}" unless url.start_with?('http')
  end

  def ensure_defaults(dmp:)
    return {} unless dmp.is_a?(Hash)

    # Ensure all contributor_id have a type (delete any empty ones)
    dmp.fetch('contributor', []).each do |contrib|
      next unless contrib.present?

      contrib.delete('contributor_id') if contrib.fetch('contributor_id', {}).fetch('identifier', '').blank?
      next unless contrib['contributor_id'].present?

      # TODO: Delete this once the UI has been fixed to include it
      contrib['contributor_id']['type'] = 'orcid' if contrib['contributor_id']['identifier'].present? &&
                                                     !contrib['contributor_id']['type'].present?
    end

    dmp.fetch('project', []).each do |project|
      next unless project.is_a?(Hash)

      # Ensure that the funding block has a status and remove the name if it is blank
      funding = project.fetch('funding', [])&.first
      if funding.is_a?(Hash)
        funding.delete('name') if funding.fetch('name', '').blank?
        project['funding'].first['funding_status'] = funding['grant_id'].present? ? 'granted' : 'planned'
      end

      # Strip out empty project start/end dates
      project.delete('start') if project['start'].blank?
      project.delete('end') if project['end'].blank?
    end

    # Ensure all dataset distributions have a title and data_access level
    dmp.fetch('dataset', []).each do |dataset|
      next unless dataset.present? && dataset.fetch('distribution', []).any?

      # If a size was specified convert it to bytes and move the value to the distribution
      size = dataset.fetch('size', {})
      val = size['value'].to_f if size['value'].present? && size['value'].match(%r{[\d\.]+}).present?
      byte_size = process_byte_size(unit: size['unit'], size: val) if val.present?
      dataset.delete('size') if dataset['size'].present?

      dataset['distribution'].each do |distro|
        distro['title'] = "Proposed distribution of '#{dataset['title']}'" unless distro['title'].present?
        distro['byte_size'] = byte_size if byte_size.present?

        # TODO: Remove this once the UI is properly pre-populating the URL
        if distro['host'].present? && distro['host']['url'].nil?
          repo = Repository.find_by(name: distro['host']['title'])
          distro['host']['url'] = repo.homepage unless repo.nil?
        end

        pii = dataset.fetch('personal_data', '').to_s.downcase.strip == 'yes'
        sensitive = dataset.fetch('sensitive_data', '').to_s.downcase.strip == 'yes'
        level = 'closed'

        # If the dataset will contain PII then default it to 'closed', if it contains sensitive data then set it to
        # 'shared', otherwise set the access level to 'open'
        distro['data_access'] = pii ? 'closed' : (sensitive ? 'shared' : 'open')
      end
    end

    dmp
  end

  # Figure out which contributor is the primary contact
  def designate_contact
    contributor = metadata['dmp'].fetch('contributor', [])
                                 .select { |c| c.present? && c.fetch('contact', false).to_s.downcase == 'true' }
                                 .first
    contact = {
      name: contributor['name'],
      mbox: contributor['mbox']
    }
    contact[:dmproadmap_affiliation] = contributor['dmproadmap_affiliation'] unless contributor['dmproadmap_affiliation'].nil?
    contact[:contact_id] = contributor['contributor_id'] unless contributor['contributor_id'].nil?
    contact[:contact_id] = { type: 'other', identifier: contributor['mbox'] } if contact[:contact_id].nil?
    JSON.parse(contact.to_json)
  end

  # Convert the incoming file size to bytes
  def process_byte_size(unit:, size:)
    return nil unless size.is_a?(Integer) || size.is_a?(Float)

    byte_size = 0.bytes + case unit.downcase.strip
                          when 'pb'
                            size.to_f.petabytes
                          when 'tb'
                            size.to_f.terabytes
                          when 'gb'
                            size.to_f.gigabytes
                          when 'mb'
                            size.to_f.megabytes
                          when 'kb'
                            size.to_f.kilobytes
                          else
                            size
                          end

    byte_size.to_i
  end
end
