# frozen_string_literal: true

# == Schema Information
#
# Table name: template_repositories
#
#  id                                :integer          not null, primary key
#  template_id                       :integer
#  repository_id                     :bigint
#
# Indexes
#
#  index_template_repositories_on_template_id    (template_id)
#  index_template_repositories_on_license_id     (repository_id)

# Object that represents a preferred license for a template
class TemplateRepository < ApplicationRecord
  belongs_to :template
  belongs_to :repository
end
