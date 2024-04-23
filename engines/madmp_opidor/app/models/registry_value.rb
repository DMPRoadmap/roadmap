# frozen_string_literal: true

# == Schema Information
#
# Table name: registry_values
#
#  id          :integer          not null, primary key
#  data        :json
#  order       :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  registry_id :integer
#
# Indexes
#
#  index_registry_values_on_registry_id  (registry_id)
#
# Foreign Keys
#
#  fk_rails_...  (registry_id => registries.id)
#

# Object that represents a registry value
class RegistryValue < ApplicationRecord
  include ValidationMessages

  # ================
  # = Associations =
  # ================

  belongs_to :registry

  # ==========
  # = Scopes =
  # ==========

  default_scope { order(order: :asc) }

  # ==========
  # = Scopes =
  # ==========

  scope :search, lambda { |term|
    search_pattern = "%#{term}%"
    where('lower(registry_values.data::text) LIKE lower(?)', search_pattern)
  }

  # Prints a representation of the registry_value according to the locale
  # If there's a label, then the registry value is a complex object, return the label
  # else returns the registry value is a simple string, returns the string
  def to_s(locale: nil)
    return data if data.nil? || locale.nil?

    if data['label'].present?
      data['label'][locale]
    else
      data[locale] || data
    end
  end
end
