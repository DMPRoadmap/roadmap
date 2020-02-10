# == Schema Information
#
# Table name: question_formats
#
#  id           :integer          not null, primary key
#  title        :string
#  description  :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  option_based :boolean          default("false")
#  formattype   :integer          default("0")
#  structured   :boolean          default("false"), not null
#

class QuestionFormat < ActiveRecord::Base
  include ValidationMessages
  include ValidationValues

  ##
  #
  FORMAT_TYPES = %i[textarea textfield radiobuttons checkbox dropdown
                    multiselectbox date rda_metadata number structured]


  # ==============
  # = Attributes =
  # ==============

  enum formattype: FORMAT_TYPES

  alias_attribute :to_s, :title

  alias_attribute :option_based?, :option_based

  # ================
  # = Associations =
  # ================

  has_many :questions


  # ===============
  # = Validations =
  # ===============

  validates :title, presence: { message: PRESENCE_MESSAGE },
                    uniqueness: { message: UNIQUENESS_MESSAGE }

  validates :description, presence: { message: PRESENCE_MESSAGE }

  validates :option_based, inclusion: { in: BOOLEAN_VALUES }


  # =================
  # = Class methods =
  # =================

  # Retrieves the id for a given formattype passed
  def self.id_for(formattype)
    where(formattype: formattype).pluck(:id).first
  end
end
