# frozen_string_literal: true

# == Schema Information
#
# Table name: research_outputs
#
#  id                      :bigint           not null, primary key
#  abbreviation            :string
#  access                  :integer          default(0), not null
#  byte_size               :bigint
#  coverage_end            :datetime
#  coverage_region         :string
#  coverage_start          :datetime
#  description             :text
#  display_order           :integer
#  is_default              :boolean         default("false")
#  mandatory_attribution   :text
#  output_type             :integer          default(3), not null
#  output_type_description :string
#  personal_data           :boolean
#  release_date            :datetime
#  sensitive_data          :boolean
#  title                   :string           not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  mime_type_id            :integer
#  plan_id                 :integer
#
# Indexes
#
#  index_research_outputs_on_output_type  (output_type)
#  index_research_outputs_on_plan_id      (plan_id)
#
class ResearchOutput < ApplicationRecord

  include Identifiable
  include ValidationMessages

  enum output_type: %i[audiovisual collection data_paper dataset event image
                       interactive_resource model_representation physical_object
                       service software sound text workflow other]

  enum access: %i[open embargoed restricted closed]

  # ================
  # = Associations =
  # ================

  belongs_to :plan, optional: true
  belongs_to :mime_type, optional: true

  # ===============
  # = Validations =
  # ===============

  validates_presence_of :output_type, :access, :title, message: PRESENCE_MESSAGE
  validates_uniqueness_of :title, :abbreviation, scope: :plan_id

  # Ensure presence of the :output_type_description if the user selected 'other'
  validates_presence_of :output_type_description, if: -> { other? }, message: PRESENCE_MESSAGE
  # Ensure that :coverage_start comes before :coverage_end
  validate :end_date_after_start_date

  # ====================
  # = Instance methods =
  # ====================

  # :mime_type is only applicable for certain :output_types
  # This method returns the applicable :mime_types
  def available_mime_types
    cat = %w[audio video] if audiovisual? || sound?
    cat = %w[image] if image?
    cat = %w[model] if model_representation?
    cat = %w[text] if data_paper? || dataset? || text?

    cat.present? ? MimeType.where(category: cat).order(:description) : []
  end

  # TODO: placeholders for once the License, Repository, Metadata Standard and
  #       Resource Type Lookups feature is built.
  #
  #       Be sure to add the scheme in the appropriate upgrade task (and to the
  #       seed.rb as well)
  def licenses
    # scheme = IdentifierScheme.find_by(name: '[name of license scheme]')
    # return [] unless scheme.present?
    # identifiers.select { |id| id.identifier_scheme = scheme }
    []
  end

  def repositories
    # scheme = IdentifierScheme.find_by(name: '[name of repository scheme]')
    # return [] unless scheme.present?
    # identifiers.select { |id| id.identifier_scheme = scheme }
    []
  end

  def metadata_standards
    # scheme = IdentifierScheme.find_by(name: '[name of openaire scheme]')
    # return [] unless scheme.present?
    # identifiers.select { |id| id.identifier_scheme = scheme }
    []
  end

  def resource_types
    # scheme = IdentifierScheme.find_by(name: '[name of resource_type scheme]')
    # return [] unless scheme.present?
    # identifiers.select { |id| id.identifier_scheme = scheme }
    []
  end

  private

  # Validation to prevent end date from coming before the start date
  def end_date_after_start_date
    # allow nil values
    return true if coverage_end.blank? || coverage_start.blank?

    errors.add(:coverage_end, _("must be after the start date")) if coverage_end < coverage_start
  end

end
