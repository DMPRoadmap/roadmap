# frozen_string_literal: true

# == Schema Information
#
# Table name: research_outputs
#
#  id                      :bigint           not null, primary key
#  abbreviation            :string
#  access                  :integer          default("open"), not null
#  byte_size               :bigint
#  description             :text
#  display_order           :integer
#  is_default              :boolean
#  output_type             :integer          default("dataset"), not null
#  output_type_description :string
#  personal_data           :boolean
#  release_date            :datetime
#  sensitive_data          :boolean
#  title                   :string(255)      not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  license_id              :bigint
#  plan_id                 :integer
#  research_outputs        :string
#
# Indexes
#
#  index_research_outputs_on_license_id   (license_id)
#  index_research_outputs_on_output_type  (output_type)
#
# Foreign Keys
#
#  fk_rails_...  (plan_id => plans.id)
#  fk_rails_...  (license_id => licenses.id)
#

# Object that represents a proposed output for a project
class ResearchOutput < ApplicationRecord
  include Identifiable
  include ValidationMessages

  DEFAULT_OUTPUT_TYPES = %w[audiovisual collection data_paper dataset event image interactive_resource
                            model_representation physical_object service software sound text workflow].freeze

  enum output_type: { audiovisual: 0, collection: 1, data_paper: 2, dataset: 3, event: 4, image: 5,
                      interactive_resource: 6, model_representation: 7, physical_object: 8,
                      service: 9, software: 10, sound: 11, text: 12, workflow: 13, other: 14 }

  enum access: { open: 0, embargoed: 1, restricted: 2, closed: 3 }

  # ================
  # = Associations =
  # ================

  belongs_to :plan, optional: true, touch: true
  belongs_to :license, optional: true

  has_and_belongs_to_many :metadata_standards
  has_and_belongs_to_many :repositories

  # ===============
  # = Validations =
  # ===============

  validates :research_output_type, :access, :title, presence: { message: PRESENCE_MESSAGE }
  validates :title, uniqueness: { case_sensitive: false, scope: :plan_id,
                                  message: UNIQUENESS_MESSAGE }
  validates :abbreviation, uniqueness: { case_sensitive: false, scope: :plan_id,
                                         allow_blank: true,
                                         message: UNIQUENESS_MESSAGE }

  validates_numericality_of :byte_size, greater_than: 0, less_than_or_equal_to: 2**63,
                                        allow_blank: true,
                                        message: '(Anticipated file size) is too large. Please enter a smaller value.'

  # ====================
  # = Instance methods =
  # ====================

  # Helper method to convert selected repository form params into Repository objects
  def repositories_attributes=(params)
    params.each do |_i, repository_params|
      repositories << Repository.find_by(id: repository_params[:id])
    end
  end

  # Helper method to convert selected metadata standard form params into MetadataStandard objects
  def metadata_standards_attributes=(params)
    params.each do |_i, metadata_standard_params|
      metadata_standards << MetadataStandard.find_by(id: metadata_standard_params[:id])
    end
  end
end
