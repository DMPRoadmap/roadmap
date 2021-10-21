# frozen_string_literal: true

# == Schema Information
#
# Table name: research_outputs
#
#  id                      :bigint           not null, primary key
#  abbreviation            :string
#  access                  :integer          default(0), not null
#  byte_size               :bigint
#  description             :text
#  display_order           :integer
#  is_default              :boolean         default("false")
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

  # ===============
  # = Validations =
  # ===============

  validates_presence_of :output_type, :access, :title, message: PRESENCE_MESSAGE
  validates_uniqueness_of :title, :abbreviation, scope: :plan_id

  # Ensure presence of the :output_type_description if the user selected 'other'
  validates_presence_of :output_type_description, if: -> { other? }, message: PRESENCE_MESSAGE

  # ====================
  # = Instance methods =
  # ====================

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

end
