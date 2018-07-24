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

class QuestionFormat < ActiveRecord::Base
  include ValidationMessages
  include ValidationValues

  ##
  #
  FORMAT_TYPES = %i[textarea textfield radiobuttons checkbox dropdown
                    multiselectbox date rda_metadata]
  ##
  # Associations
  has_many :questions

  enum formattype: FORMAT_TYPES

  validates :title, presence: { message: PRESENCE_MESSAGE },
                    uniqueness: { message: UNIQUENESS_MESSAGE }

  validates :description, presence: { message: PRESENCE_MESSAGE }

  validates :option_based, inclusion: { in: BOOLEAN_VALUES }

  # Retrieves the id for a given formattype passed
  scope :id_for, -> (formattype) { where(formattype: formattype).pluck(:id).first }

  ##
  # Define Bit Field Values so we can test a format without doing string comps
  # Column type

  # EVALUATE CLASS AND INSTANCE METHODS BELOW
  #
  # What do they do? do they do it efficiently, and do we need them?


  ##
  # gives the title of the question_format
  #
  # @return [String] title of the question_format
  def to_s
    "#{title}"
  end

end
