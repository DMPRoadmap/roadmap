# frozen_string_literal: true

module AllowedQuestionFormats

  private

  # The QuestionFormat "Multi select box" is no longer being used for new templates
  def allowed_question_formats
    QuestionFormat.where.not(title: "Multi select box").order(:title)
  end

end
