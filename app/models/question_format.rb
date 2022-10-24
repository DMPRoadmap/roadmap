# frozen_string_literal: true

# == Schema Information
#
# Table name: question_formats
#
#  id           :integer          not null, primary key
#  description  :text
#  formattype   :integer          default(0)
#  option_based :boolean          default(FALSE)
#  title        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

# Object that represents a question type
class QuestionFormat < ApplicationRecord
  ##
  #
  FORMAT_TYPES = %i[textarea textfield radiobuttons checkbox dropdown
                    multiselectbox date rda_metadata].freeze

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
                    uniqueness: { message: UNIQUENESS_MESSAGE,
                                  case_sensitive: false }

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
