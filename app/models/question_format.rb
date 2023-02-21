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
                    uniqueness: { message: UNIQUENESS_MESSAGE }

  validates :description, presence: { message: PRESENCE_MESSAGE }

  validates :option_based, inclusion: { in: BOOLEAN_VALUES }

  # ===========================
  # = Public instance methods =
  # ===========================

  # title and description are translated through the translation gem
  def title
    title = read_attribute(:title)
    _(title) unless title.blank?
  end

  def description
    description = read_attribute(:description)
    _(description) unless description.blank?
  end

  # =================
  # = Class methods =
  # =================

  # Retrieves the id for a given formattype passed
  def self.id_for(formattype)
    where(formattype: formattype).pluck(:id).first
  end
end
