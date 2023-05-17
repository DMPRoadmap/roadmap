# frozen_string_literal: true

# == Schema Information
#
# Table name: template_output_types
#
#  id                                :integer          not null, primary key
#  template_id                       :integer
#  research_output_type              :string
#
# Indexes
#
#  index_template_output_types_on_template_id    (template_id)

# Object that represents customized output types for a template
class TemplateOutputType < ApplicationRecord
  belongs_to :template
  attribute :research_output_type
end
