# == Schema Information
#
# Table name: research_outputs
#
#  id                      :integer          not null, primary key
#  abbreviation            :string
#  order                   :integer
#  fullname                :string
#  is_default              :boolean          default("false")
#  plan_id                 :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  pid                     :string
#  other_type_label        :string
#  research_output_type_id :integer
#
# Indexes
#
#  index_research_outputs_on_plan_id                  (plan_id)
#  index_research_outputs_on_research_output_type_id  (research_output_type_id)
#

class ResearchOutput < ActiveRecord::Base
  include ValidationMessages

  after_save :create_or_update_fragments
  after_destroy :destroy_json_fragment
  
  # ================
  # = Associations =
  # ================
  belongs_to :plan

  belongs_to :type, class_name: ResearchOutputType, foreign_key: "research_output_type_id"

  has_many :answers, dependent: :destroy


  # ===============
  # = Validations =
  # ===============

  validates :abbreviation, presence: { message: PRESENCE_MESSAGE }

  validates :fullname, presence: { message: PRESENCE_MESSAGE }

  validates :type, presence: { message: PRESENCE_MESSAGE }

  validates :plan, presence: { message: PRESENCE_MESSAGE }


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

  def get_answers_for_section(section_id)
    self.answers.select { |answer| answer.question_id.in?(Section.find(section_id).questions.pluck(:id)) }
  end

  def json_fragment
    Fragment::ResearchOutput.where("(data->>'research_output_id')::int = ?", id).first
  end

  def destroy_json_fragment
    Fragment::ResearchOutput.where("(data->>'research_output_id')::int = ?", id).destroy_all
  end

  def create_or_update_fragments
    fragment = self.json_fragment()
    dmp_fragment = self.plan.json_fragment()
    if fragment.nil?
      fragment = Fragment::ResearchOutput.create(
        data: {
          "research_output_id" => self.id,
          "title" => self.abbreviation,
          "description" => self.fullname,
          "type" => self.type.label
        },
        dmp_id: dmp_fragment.id,
        parent_id: dmp_fragment.id
      )
    else
      fragment.update(
        data: {
          "research_output_id" => self.id,
          "title" => self.abbreviation,
          "description" => self.fullname,
          "type" => self.type.label
        }
      )
    end
  end

  ##
  # deep copy the given research output
  #
  # Returns Research output
  def self.deep_copy(research_output)
    research_output.dup
  end
  

end
