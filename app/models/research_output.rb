# == Schema Information
#
# Table name: research_outputs
#
#  id                      :integer          not null, primary key
#  abbreviation            :string
#  fullname                :string
#  is_default              :boolean          default(FALSE)
#  order                   :integer
#  other_type_label        :string
#  pid                     :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  plan_id                 :integer
#  research_output_type_id :integer
#
# Indexes
#
#  index_research_outputs_on_plan_id                  (plan_id)
#  index_research_outputs_on_research_output_type_id  (research_output_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (plan_id => plans.id)
#  fk_rails_...  (research_output_type_id => research_output_types.id)
#

class ResearchOutput < ActiveRecord::Base
  include ValidationMessages
  
  # ================
  # = Associations =
  # ================
  belongs_to :plan

  belongs_to :research_output_type

  has_many :answers, dependent: :destroy

  # ===============
  # = Validations =
  # ===============

  validates :abbreviation, presence: { message: PRESENCE_MESSAGE }

  validates :fullname, presence: { message: PRESENCE_MESSAGE }


  # ==========
  # = Scopes =
  # ==========

  default_scope { order(order: :asc) }


  # =================
  # = Class methods =
  # =================

  def main?
    eql?(plan.research_outputs.where(order: 1).first)
  end

  # Return main research output
  def get_main
    plan.research_outputs.first
  end

  def has_common_answers?(section_id)
    self.answers.each do |answer|
      if answer.question_id.in?(Section.find(section_id).questions.pluck(:id)) && answer.is_common
        return true
      end
    end
    return false
  end

  ##
  # deep copy the given research output
  #
  # Returns Research output
  def self.deep_copy(research_output)
    research_output.dup
  end

end
