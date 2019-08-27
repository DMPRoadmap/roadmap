# == Schema Information
#
# Table name: prefs
#
#  id       :integer          not null, primary key
#  settings :text
#  user_id  :integer
#

class Pref < ActiveRecord::Base
  include ValidationMessages

  ##
  # Serialize prefs to JSON
  # The settings object only stores deviations from the default
  serialize :settings, JSON

  # ================
  # = Associations =
  # ================
  belongs_to :user

  # ===============
  # = Validations =
  # ===============

  validates :user, presence: { message: PRESENCE_MESSAGE }

  validates :settings, presence: { message: PRESENCE_MESSAGE }

  # The default preferences
  #
  # Returns Hash
  def self.default_settings
    Branding.fetch(:preferences)
  end

end
