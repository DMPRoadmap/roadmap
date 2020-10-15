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
      # Fetch the first question linked with a ResearchOutputDescription schema
      description_question = self.plan.questions.joins(:madmp_schema)
                                  .find_by(:madmp_schemas => { :classname => 'research_output_description' } )
      
      # Creates the main ResearchOutput fragment
      fragment = Fragment::ResearchOutput.create(
        data: {
          "research_output_id" => self.id
        },
        madmp_schema_id: MadmpSchema.find_by(classname: "research_output").id,
        dmp_id: dmp_fragment.id,
        parent_id: dmp_fragment.id
      )
      fragment_description = Fragment::ResearchOutputDescription.create(
        data: {
          "title" => self.fullname
        },
        madmp_schema_id: MadmpSchema.find_by(classname: "research_output_description").id,
        dmp_id: dmp_fragment.id,
        parent_id: fragment.id
      )

      unless description_question.nil?
        # Create a new answer for the ResearchOutputDescription Question
        # This answer will be displayed in the Write Plan tab, pre filled with the ResearchOutputDescription info
        fragment_description.answer = Answer.create(
          question_id: description_question.id,
          research_output_id: self.id,
          plan_id: self.plan.id,
          user_id: self.plan.users.first.id
        )
        fragment_description.save!
      end
    else
      data = fragment.research_output_description.data.merge({
        "title" => self.fullname
      })
      fragment.research_output_description.update(data: data)
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
