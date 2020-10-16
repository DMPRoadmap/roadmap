# == Schema Information
#
# Table name: registry_values
#
#  id         :integer          not null, primary key
#  data       :json
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  registry_id :integer
#

class RegistryValue < ActiveRecord::Base

  # ================
  # = Associations =
  # ================

  belongs_to :registry

  # Prints a representation of the registry_value according to the locale
  # If there's a label, then the registry value is a complex object, return the label
  # else returns the registry value is a simple string, returns the string
  def to_s(locale)
    if data["label"].present?
      data["label"][locale]
    elsif data["value"].present?
      data["value"][locale] || data["value"]
    end
  end

end
