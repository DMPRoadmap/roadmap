class AnswerForCorrectTemplateValidator < ActiveModel::Validator
  def validate(record)
    # Make sure that the question and plan belong to the same template!
    unless record.plan.nil? || record.question.nil?
      unless record.plan.template == record.question.section.phase.template
        record.errors[:question] << I18n.t('helpers.answer.question_must_belong_to_correct_template')
      end
    end
  end
end