# frozen_string_literal: true

# == Schema Information
#
# Table name: template_licences
#
#  id                                :integer          not null, primary key
#  template_id                       :integer
#  license_id                        :bigint
#
# Indexes
#
#  index_template_licenses_on_template_id    (template_id)
#  index_template_licenses_on_license_id     (license_id)

# Object that represents a preferred license for a template
class TemplateLicense < ApplicationRecord
  belongs_to :template
  belongs_to :license
end
