# == Schema Information
#
# Table name: region_languages
#
#  id          :integer          not null, primary key
#  default     :boolean          default(FALSE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  language_id :integer
#  region_id   :integer
#

class RegionLanguage < ActiveRecord::Base

  belongs_to :region

  belongs_to :language

  # ===============
  # = Validations =
  # ===============

  validate :only_default_for_region

  # ==========
  # = Scopes =
  # ==========

  scope :default, -> { where(default: true) }

  # =============
  # = Callbacks =
  # =============

  before_destroy :set_new_default, if: :default?

  private

  # Validate this is the only RegionLanguage that is default for this Region
  #
  # Returns true
  #
  def only_default_for_region
    if RegionLanguage.where(region_id: region_id, default: true).exists?
      errors.add(:default, "is already present for this Region")
    end
  end

  # Set another RegionLanguage as the default if we're destroying the current default
  def set_new_default
    RegionLanguage
      .where(region_id: region_id, default: false)
      .limit(1)
      .update_all(default: true)
  end

end
