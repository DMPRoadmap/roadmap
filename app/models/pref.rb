class Pref < ActiveRecord::Base
  ##
  # Serialize prefs to JSON
  # The settings object only stores deviations from the default
  serialize :settings, JSON

  ##
  # Associations
  belongs_to :user

  ##
  # Returns the hash generated from default preferences
  #
  # @return [JSON] preferences hash
  def self.default_settings
    return Rails.configuration.branding[:preferences]
  end

end