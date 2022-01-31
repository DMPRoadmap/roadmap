# frozen_string_literal: true

# Controller that gets Questions types that allow multiple selections
# TODO: this could likely just live on the model!
module AllowedQuestionFormats
  private

  # The QuestionFormat "Multi select box" is no longer being used for new templates
  def allowed_question_formats
    QuestionFormat.where.not(title: 'Multi select box').order(:title)
  end
end
