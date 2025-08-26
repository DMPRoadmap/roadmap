# frozen_string_literal: true

# == Schema Information
#
# Table name: question_identifiers
#
#  id           :integer          not null, primary key
#  question_id  :integer
#  value        :string
#  name         :string           
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Foreign Keys
#
#  fk_rails_...  (question_id => questions.id)
#

# Object that represents a question identifier 
class QuestionIdentifier < ApplicationRecord
  include VersionableModel

  # ================
  # = Associations =
  # ================

  belongs_to :question

  has_one :section, through: :question

  has_one :phase, through: :question

  has_one :template, through: :question

  # ===============
  # = Validations =
  # ===============

  validate :value_unique_within_template
  
 # ===========================
 # = Public instance methods =
 # ===========================

  def deep_copy(**options)
    copy = dup
    copy.question_id = options.fetch(:question_id, nil)
    copy.save!(validate: false)  if options.fetch(:save, false)
    options[:question_identifier_id] = copy.id
    copy
  end
  
# ===========================
# = Private instance methods =
# ===========================  
private

# the method verifies if a 'value' is unique on a specific template. 
def value_unique_within_template

  template = Template.find(question.section.phase.template_id)
  questions = template.questions
  
  if value_changed? 
    questions.each do |current_question|
      current_question.question_identifiers.each do |question_identifier|
        if value == question_identifier.value
          errors.add("- 'value' must be unique within the template.", '')
          break
        end
      end
      
    end
    
  end
end



end
  