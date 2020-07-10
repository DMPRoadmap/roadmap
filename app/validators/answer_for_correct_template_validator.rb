# frozen_string_literal: true

class AnswerForCorrectTemplateValidator < ActiveModel::Validator

  def validate(record)
    return if record.plan.nil? || record.question.nil?
    # Make sure that the question and plan belong to the same template!
    return unless record.plan.template == record.question.section.phase.template

    record.errors[:question] << I18n.t("helpers.answer.question_must_belong_to_correct_template")
  end

end
