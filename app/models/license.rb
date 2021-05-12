# frozen_string_literal: true

# == Schema Information
#
# Table name: licenses
#
#  id           :integer          not null, primary key
#  name         :string           not null
#  identifier   :string
#  url          :string
#  osi_approved :boolean          default: false
#  deprecated   :boolean          default: false
#  created_at   :datetime
#  updated_at   :datetime
#
# Indexes
#
#  index_licenses_on_identifier               (name)
#  index_licenses_on_url                      (url)
#  index_licenses_on_identifier_and_criteria  (identifier, osi_approved, deprecated)
#
class License < ApplicationRecord

  # ================
  # = Associations =
  # ================

  has_many :research_outputs

  # ==========
  # = Scopes =
  # ==========

  scope :selectable, lambda {
    where(deprecated: false)
  }

  scope :preferred, lambda {
    # Fetch the list of preferred license from the config.
    preferences = Rails.configuration.x.preferred_licenses || []
    return selectable unless preferences.is_a?(Array) && preferences.any?

    licenses = preferences.map do |preference|
      # If `%{latest}` was specified then grab the most current version
      pref = preference.gsub("%{latest}", "[0-9\\.]+$")
      rslts = preference.include?("%{latest}") ? where("identifier REGEXP ?", pref) : where(identifier: pref)
      rslts.order(:identifier).last
    end
    # Remove any preferred licenses that could not be found in the table
    licenses.compact
  }

end