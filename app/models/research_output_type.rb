# frozen_string_literal: true

# == Schema Information
#
# Table name: research_output_types
#
#  id         :integer          not null, primary key
#  label      :string           not null
#  slug       :string           not null
#  is_other   :boolean          default("false"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# Object that represents a research output type
class ResearchOutputType < ActiveRecord::Base
  has_many :research_outputs

  ##
  # Before save & create, generate the slug
  before_save :generate_slug

  def generate_slug
    self.slug = label.parameterize if label.present?
  end
end
