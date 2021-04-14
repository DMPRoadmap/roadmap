# frozen_string_literal: true

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
    preferences = Rails.configuration.x.preferred_licenses
    return selectable unless preferences.is_a?(Array) && preferences.any?

    preferences.map do |preference|
      # If `%{latest}` was specified then grab the most current version
      pref = preference.gsub("%{latest}", "[0-9\\.]+$")
      rslts = preference.include?("%{latest}") ? where("identifier REGEXP ?", pref) : where(identifier: pref)
      rslts.order(:identifier).last
    end
  }

end