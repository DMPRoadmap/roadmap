# frozen_string_literal: true

module TemplateHelper

  def build_template(nbr_phases = 0, nbr_sections = 0, nbr_questions = 0)
    template = create(:template, phases: nbr_phases)

    template.phases.each do |phase|
      nbr_sections.times do
        section = create(:section, phase: phase)
        nbr_questions.times do
          create(:question, section: section)
        end
      end
    end
    template
  end

end
