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

  validates :default, uniqueness: { scope: :region_id }


  # ==========
  # = Scopes =
  # ==========

  scope :default, -> { where(default: true) }

end
