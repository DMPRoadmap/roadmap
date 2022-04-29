# frozen_string_literal: true

xml.instruct!
# rubocop:disable Metrics/BlockLength
xml.plan('id' => @plan.id) do
  xml.project(@plan.project.title, 'id' => @plan.project.id)
  xml.phase(@plan.version.phase.title, 'id' => @plan.version.phase.id)

  details = @exported_plan.admin_details
  if details.present?
    xml.details do
      details.each do |field|
        value = @exported_plan.send(field)
        xml.detail(value, title: admin_field_t(field)) if value.present?
      end
    end
  end

  xml.sections do
    @exported_plan.sections.each do |section|
      xml.section('id' => section.id, 'number' => section.number, 'title' => section.title) do
        xml.answers do
          questions = @exported_plan.questions_for_section(section.id)
          questions.each do |question|
            xml.question('id' => question.id, 'number' => question.number,
                         'question_format' => question.question_format) do
              q_format = question.question_format
              xml.question_text question.text
              answer = @plan.answer(question.id, false)
              unless answer.nil?
                xml.answer('id' => answer.id) do # should add user and date info here
                  if q_format.title == _('Check box') || q_format.title == _('Multi select box') ||
                     q_format.title == _('Radio buttons') || q_format.title == _('Dropdown')
                    xml.selections do
                      answer.options.each do |option|
                        xml.selection(option.text, 'id' => option.id, 'number' => option.number)
                      end
                    end
                    xml.comment_text answer.text if question.option_comment_display == true
                  else
                    xml.answer_text answer.text
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
