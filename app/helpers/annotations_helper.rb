# frozen_string_literal: true

module AnnotationsHelper

  TOOLTIPS_FOR_TEXT = {
    example_answer: _('You can add an example answer to help users respond. These will be presented above the answer box and can be copied/ pasted.'),
    guidance: _("Enter specific guidance to accompany this question. If you have guidance by themes too, this will be pulled in based on your selections below so it's best not to duplicate too much text.")
  }


  def tooltip_for_annotation_text(annotation)
    TOOLTIPS_FOR_TEXT[annotation.type.to_sym]
  end
end
