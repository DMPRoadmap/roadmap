# frozen_string_literal: true

# == Schema Information
#
# Table name: licenses
#
#  id           :bigint           not null, primary key
#  deprecated   :boolean          default(FALSE)
#  identifier   :string           not null
#  name         :string           not null
#  osi_approved :boolean          default(FALSE)
#  uri          :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_license_on_identifier_and_criteria  (identifier,osi_approved,deprecated)
#  index_licenses_on_identifier              (identifier)
#  index_licenses_on_uri                     (uri)
#
class License < ApplicationRecord
  # ================
  # = Associations =
  # ================

  has_many :research_outputs

  belongs_to :org, optional: true

  # ==========
  # = Scopes =
  # ==========

  scope :selectable, lambda {
    where(deprecated: false)
  }

  scope :preferred, lambda {
    # Fetch the list of preferred license from the config.
    preferences = Rails.configuration.x.madmp.preferred_licenses || []
    return selectable unless preferences.is_a?(Array) && preferences.any?

    licenses = preferences.map do |preference|
      # If `%{latest}` was specified then grab the most current version
      pref = preference.gsub('%{latest}', '[0-9\\.]+$')
      where_clause = safe_regexp_where_clause(column: 'identifier')
      rslts = preference.include?('%{latest}') ? where(where_clause, pref) : where(identifier: pref)
      rslts.order(:identifier).last
    end
    # Remove any preferred licenses that could not be found in the table
    licenses.compact
  }

  # varchar(255) NOT NULL
  validates :name,
            presence: { message: PRESENCE_MESSAGE },
            length: { in: 0..255, allow_nil: false }

  # varchar(255) NOT NULL
  validates :identifier,
            presence: { message: PRESENCE_MESSAGE },
            length: { in: 0..255, allow_nil: false }
end
