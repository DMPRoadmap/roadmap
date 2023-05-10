# frozen_string_literal: true

# == Schema Information
#
# Table name: template_metadata_standards
#
#  id                                :integer          not null, primary key
#  template_id                       :integer
#  metadata_standard_id              :bigint
#
# Indexes
#
#  index_template_metadata_standards_on_template_id    (template_id)
#  index_template_metadata_standards_on_metadata_standard_id     (metadata_standard_id)

# Object that represents a preferred license for a template
class TemplateMetadataStandard < ApplicationRecord
  belongs_to :template
  belongs_to :metadata_standard
end
